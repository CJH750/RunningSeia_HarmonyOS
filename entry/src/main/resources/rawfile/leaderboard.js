var currentPage = 1;
var currentType = 'all';
var currentQuery = '';
var currentDate = '';
var currentPageSize = '10';
var allowedTypes = ['day', 'week', 'month', 'all'];
var allowedPageSizes = ['10', '20', '50', '100', 'all'];
var allData = [];
var sortState = { column: null, asc: true };
var currentTotal = 0;
var currentDataPageSize = 10;

function escapeHTML(value) {
    return String(value == null ? '' : value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function normalizeType(type) {
    return allowedTypes.indexOf(type) !== -1 ? type : 'day';
}

function normalizePage(page) {
    var num = parseInt(page, 10);
    return isNaN(num) || num < 1 ? 1 : num;
}

function normalizePageSize(pageSize) {
    var str = String(pageSize || '10');
    return allowedPageSizes.indexOf(str) !== -1 ? str : '10';
}

function parseResponse(res) {
    var contentType = res.headers.get("Content-Type") || "";
    var isHtml = contentType.indexOf("text/html") !== -1;
    if (!res.ok || isHtml) {
      return res.text().then(function (text) {
        if (isHtml) {
          showServerError(text);
        }
        throw new Error("server error " + res.status);
      });
    }
    return res.json().catch(function () {
      return res.text().then(function (text) {
        throw new Error("invalid json response");
      });
    });
  }

var serverErrorModal = document.getElementById("serverErrorModal");
var serverErrorFrame = document.getElementById("serverErrorFrame");
var serverErrorClose = document.getElementById("serverErrorClose");

if (serverErrorClose) {
    serverErrorClose.addEventListener("click", function () {
        serverErrorModal.classList.add("hidden");
        serverErrorFrame.srcdoc = "";
    });
    serverErrorModal.addEventListener("click", function (e) {
        if (e.target === serverErrorModal) {
            serverErrorModal.classList.add("hidden");
            serverErrorFrame.srcdoc = "";
        }
    });
}

function showServerError(html) {
    if (serverErrorFrame) {
        serverErrorFrame.srcdoc = html;
        serverErrorModal.classList.remove("hidden");
    }
}

function buildPageHref(type, pageSize, page, query, date) {
    var params = new URLSearchParams();
    params.set('type', normalizeType(type));
    params.set('pageSize', normalizePageSize(pageSize));
    params.set('page', normalizePage(page));
    if (query) params.set('query', query);
    if (date) params.set('date', date);
    return '?' + params.toString();
}

function getQueryParam(name) {
    var urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(name);
}

function updateURL(type, page, query, pageSize, date) {
    var url = new URL(window.location);
    if (type) url.searchParams.set('type', normalizeType(type));
    if (page) url.searchParams.set('page', normalizePage(page));
    if (query) { url.searchParams.set('query', query); url.searchParams.delete('type'); }
    else url.searchParams.delete('query');
    var safePageSize = normalizePageSize(pageSize);
    if (safePageSize !== '10') url.searchParams.set('pageSize', safePageSize);
    else url.searchParams.delete('pageSize');
    if (date) url.searchParams.set('date', date);
    else url.searchParams.delete('date');
    window.history.replaceState({}, '', url);
}

function getTypeLabel(type) {
    var labels = { 'day': '日', 'week': '周', 'month': '月', 'all': '总' };
    return labels[type] || '总';
}

function formatTime(dateStr) {
    if (!dateStr) return '';
    var date = new Date(dateStr);
    var year = date.getFullYear();
    var month = String(date.getMonth() + 1).padStart(2, '0');
    var day = String(date.getDate()).padStart(2, '0');
    var hours = String(date.getHours()).padStart(2, '0');
    var minutes = String(date.getMinutes()).padStart(2, '0');
    var seconds = String(date.getSeconds()).padStart(2, '0');
    return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
}

function sortDataArray(arr, column, asc) {
    var dir = asc ? 1 : -1;
    arr.sort(function(a, b) {
        var va, vb;
        switch (column) {
            case 'rank': va = a._rank || 0; vb = b._rank || 0; return (va - vb) * dir;
            case 'nickname': va = a.nickname || ''; vb = b.nickname || ''; return va.localeCompare(vb, 'zh-CN') * dir;
            case 'score': va = parseFloat(a.score) || 0; vb = parseFloat(b.score) || 0; return (va - vb) * dir;
            case 'message': va = a.message || ''; vb = b.message || ''; return va.localeCompare(vb, 'zh-CN') * dir;
            case 'location': va = a.location || ''; vb = b.location || ''; return va.localeCompare(vb, 'zh-CN') * dir;
            case 'device': va = a.device || ''; vb = b.device || ''; return va.localeCompare(vb, 'zh-CN') * dir;
            case 'updated_at': va = a.updated_at || a.created_at || ''; vb = b.updated_at || b.created_at || ''; return (new Date(va) - new Date(vb)) * dir;
            default: return 0;
        }
    });
}

function updateSortIndicators() {
    document.querySelectorAll('.rank-table th.sortable').forEach(function(th) {
        var arrow = th.querySelector('.sort-arrow');
        var col = th.getAttribute('data-column');
        if (col === sortState.column) {
            arrow.textContent = sortState.asc ? ' ▲' : ' ▼';
            th.classList.add('sort-active');
        } else {
            arrow.textContent = '';
            th.classList.remove('sort-active');
        }
    });
}

function getRankSuffix(rank) {
    if (rank === 1) return 'st';
    if (rank === 2) return 'nd';
    if (rank === 3) return 'rd';
    return 'th';
}

function renderTable(data, page, pageSize, incremental) {
    var tableBody = document.getElementById('rankTableBody');
    if (!tableBody) return;
    var startRank = (page - 1) * pageSize + 1;
    if (data.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="7" class="rank-loading">暂无数据</td></tr>';
        return;
    }
    if (incremental) {
        tableBody.innerHTML = '';
        var idx = 0;
        var chunkSize = 150;
        function renderChunk() {
            var html = '';
            var end = Math.min(idx + chunkSize, data.length);
            for (; idx < end; idx++) {
                var item = data[idx];
                var rank = startRank + idx;
                var time = item.updated_at ? formatTime(item.updated_at) : formatTime(item.created_at);
                html += '<tr><td class="col-rank">' + rank + getRankSuffix(rank) + '</td>' +
                    '<td class="col-nick">' + escapeHTML(item.nickname) + '</td>' +
                    '<td class="col-score">' + escapeHTML(item.score) + '</td>' +
                    '<td class="col-msg">' + escapeHTML(item.message || '') + '</td>' +
                    '<td class="col-loc">' + escapeHTML(item.location) + '</td>' +
                    '<td class="col-dev">' + escapeHTML(item.device) + '</td>' +
                    '<td class="col-time">' + escapeHTML(time) + '</td></tr>';
            }
            tableBody.insertAdjacentHTML('beforeend', html);
            if (idx < data.length) setTimeout(renderChunk, 0);
        }
        renderChunk();
        return;
    }
    var html = '';
    data.forEach(function(item, index) {
        var rank = startRank + index;
        var time = item.updated_at ? formatTime(item.updated_at) : formatTime(item.created_at);
        html += '<tr><td class="col-rank">' + rank + getRankSuffix(rank) + '</td>' +
            '<td class="col-nick">' + escapeHTML(item.nickname) + '</td>' +
            '<td class="col-score">' + escapeHTML(item.score) + '</td>' +
            '<td class="col-msg">' + escapeHTML(item.message || '') + '</td>' +
            '<td class="col-loc">' + escapeHTML(item.location) + '</td>' +
            '<td class="col-dev">' + escapeHTML(item.device) + '</td>' +
            '<td class="col-time">' + escapeHTML(time) + '</td></tr>';
    });
    tableBody.innerHTML = html;
}

function renderCards(data, page, pageSize, incremental) {
    var rankList = document.getElementById('rankList');
    if (!rankList) return;
    var startRank = (page - 1) * pageSize + 1;
    if (data.length === 0) {
        rankList.innerHTML = '<div class="rank-item no-data"><div>暂无数据</div></div>';
        return;
    }
    if (incremental) {
        rankList.innerHTML = '';
        var idx = 0;
        var chunkSize = 50;
        function renderChunk() {
            var html = '';
            var end = Math.min(idx + chunkSize, data.length);
            for (; idx < end; idx++) {
                var item = data[idx];
                var rank = startRank + idx;
                var time = item.updated_at ? formatTime(item.updated_at) : formatTime(item.created_at);
                html += '<div class="rank-item"><div class="rank-item-header">' +
                    '<span class="rank-name">' + rank + getRankSuffix(rank) + ' ' + escapeHTML(item.nickname) + '</span>' +
                    '<span class="rank-time">' + escapeHTML(time) + '</span></div>' +
                    '<div class="rank-item-body"><div class="rank-score">SCORE: <strong>' + escapeHTML(item.score) + '</strong></div>' +
                    '<div class="rank-info">' + escapeHTML(item.device) + ' - ' + escapeHTML(item.location) + '</div>' +
                    (item.message ? '<div class="rank-message">' + escapeHTML(item.message) + '</div>' : '') +
                    '</div></div>';
            }
            rankList.insertAdjacentHTML('beforeend', html);
            if (idx < data.length) setTimeout(renderChunk, 0);
        }
        renderChunk();
        return;
    }
    var html = '';
    data.forEach(function(item, index) {
        var rank = startRank + index;
        var time = item.updated_at ? formatTime(item.updated_at) : formatTime(item.created_at);
        html += '<div class="rank-item"><div class="rank-item-header">' +
            '<span class="rank-name">' + rank + getRankSuffix(rank) + ' ' + escapeHTML(item.nickname) + '</span>' +
            '<span class="rank-time">' + escapeHTML(time) + '</span></div>' +
            '<div class="rank-item-body"><div class="rank-score">SCORE: <strong>' + escapeHTML(item.score) + '</strong></div>' +
            '<div class="rank-info">' + escapeHTML(item.device) + ' - ' + escapeHTML(item.location) + '</div>' +
            (item.message ? '<div class="rank-message">' + escapeHTML(item.message) + '</div>' : '') +
            '</div></div>';
    });
    rankList.innerHTML = html;
}

function renderPagination(total, pageSize, currentPage) {
    var pagination = document.getElementById('pagination');
    if (!pagination) return;
    var totalPages = Math.ceil(total / pageSize);
    var safeType = normalizeType(currentType);
    var safePageSize = normalizePageSize(currentPageSize);
    if (totalPages <= 1) { pagination.innerHTML = ''; return; }
    var html = '<ul class="pagination">';
    if (currentPage > 1) html += '<li><a href="' + buildPageHref(safeType, safePageSize, currentPage - 1, currentQuery, currentDate) + '">&laquo;</a></li>';
    else html += '<li class="disabled"><a href="#">&laquo;</a></li>';
    var pagesToShow = [];
    pagesToShow.push(1);
    var pageStart = Math.max(2, currentPage - 2);
    var pageEnd = Math.min(totalPages - 1, currentPage + 2);
    if (pageStart > 2) pagesToShow.push("...");
    for (var i = pageStart; i <= pageEnd; i++) pagesToShow.push(i);
    if (pageEnd < totalPages - 1) pagesToShow.push("...");
    if (totalPages > 1) pagesToShow.push(totalPages);
    for (var j = 0; j < pagesToShow.length; j++) {
        var p = pagesToShow[j];
        if (p === "...") html += '<li class="disabled"><a href="#">&hellip;</a></li>';
        else if (p === currentPage) html += '<li class="active"><a href="' + buildPageHref(safeType, safePageSize, p, currentQuery, currentDate) + '">' + p + '</a></li>';
        else html += '<li><a href="' + buildPageHref(safeType, safePageSize, p, currentQuery, currentDate) + '">' + p + '</a></li>';
    }
    if (currentPage < totalPages) html += '<li><a href="' + buildPageHref(safeType, safePageSize, currentPage + 1, currentQuery, currentDate) + '">&raquo;</a></li>';
    else html += '<li class="disabled"><a href="#">&raquo;</a></li>';
    html += '</ul>';
    pagination.innerHTML = html;
}

function updateNavActive() {
    var navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(function(item) { item.classList.remove('active'); });
    if (currentQuery) return;
    var activeItem = document.querySelector('.nav-item[href="?type=' + currentType + '"]');
    if (activeItem) activeItem.classList.add('active');
}

function loadData(type, page, pageSize, query, date) {
    var url = 'api/get_scores.php';
    var params = [];
    var safeType = normalizeType(type || currentType);
    var safePage = normalizePage(page || currentPage);
    var safePageSize = normalizePageSize(pageSize || currentPageSize);
    var safeDate = date || currentDate;
    if (safeType) params.push('type=' + encodeURIComponent(safeType));
    if (safePage) params.push('page=' + safePage);
    if (safePageSize) params.push('pageSize=' + encodeURIComponent(safePageSize));
    if (query) params.push('query=' + encodeURIComponent(query));
    if (safeDate) params.push('date=' + encodeURIComponent(safeDate));
    if (params.length > 0) url += '?' + params.join('&');

    fetch(url)
        .then(parseResponse)
        .then(function(data) {
            if (data.code === 0) {
                currentType = safeType;
                currentPage = safePage;
                currentQuery = query || '';
                currentDate = safeDate;
                currentPageSize = safePageSize;
                currentTotal = data.total;
                currentDataPageSize = data.pageSize;
                document.getElementById('rankTitle').textContent =
                    (currentQuery ? '搜索: ' + currentQuery : '排行榜[' + getTypeLabel(currentType) + ']');
                var recordCount = document.getElementById('recordCount');
                if (recordCount) recordCount.textContent = '共 ' + data.total + ' 条记录';
                allData = data.data.map(function(item, index) {
                    item._rank = (data.page - 1) * data.pageSize + index + 1;
                    return item;
                });
                if (sortState.column) sortDataArray(allData, sortState.column, sortState.asc);
                var isAllMode = safePageSize === 'all';
                renderTable(allData, data.page, data.pageSize, isAllMode);
                renderCards(allData, data.page, data.pageSize, isAllMode);
                renderPagination(data.total, data.pageSize, data.page);
                updateNavActive();
                updateSortIndicators();
            } else {
                var tableBody = document.getElementById('rankTableBody');
                var rankList = document.getElementById('rankList');
                if (tableBody) tableBody.innerHTML = '<tr><td colspan="7" class="rank-loading">' + (data.message || '查询失败') + '</td></tr>';
                if (rankList) rankList.innerHTML = '<div class="rank-item no-data"><div>' + (data.message || '查询失败') + '</div></div>';
            }
        })
        .catch(function() {
            var tableBody = document.getElementById('rankTableBody');
            var rankList = document.getElementById('rankList');
            if (tableBody) tableBody.innerHTML = '<tr><td colspan="7" class="rank-loading">查询失败，请稍后重试</td></tr>';
            if (rankList) rankList.innerHTML = '<div class="rank-item no-data"><div>查询失败，请稍后重试</div></div>';
        });
}

function init() {
    var type = normalizeType(getQueryParam('type') || 'day');
    var page = normalizePage(getQueryParam('page') || 1);
    var query = getQueryParam('query') || '';
    var date = getQueryParam('date') || '';
    var pageSize = normalizePageSize(getQueryParam('pageSize') || '10');
    currentType = type;
    currentPage = page;
    currentQuery = query;
    currentDate = date;
    currentPageSize = pageSize;
    updateNavActive();
    if (query) document.getElementById('searchInput').value = query;
    document.getElementById('pageSizeSelect').value = pageSize;
    if (date) document.getElementById('datePicker').value = date;
    var navToggle = document.querySelector('.nav-toggle');
    var navMenu = document.querySelector('.nav-menu');
    if (navToggle) navToggle.addEventListener('click', function() { navMenu.classList.toggle('active'); });
    var searchBtn = document.getElementById('searchBtn');
    var searchInput = document.getElementById('searchInput');
    if (searchBtn) searchBtn.addEventListener('click', function() { loadData(null, 1, currentPageSize, searchInput.value.trim(), currentDate); });
    if (searchInput) searchInput.addEventListener('keyup', function(e) { if (e.key === 'Enter') loadData(null, 1, currentPageSize, searchInput.value.trim(), currentDate); });
    var pageSizeSelect = document.getElementById('pageSizeSelect');
    if (pageSizeSelect) pageSizeSelect.addEventListener('change', function() {
        currentPageSize = pageSizeSelect.value;
        loadData(currentType, 1, currentPageSize, currentQuery, currentDate);
    });
    var datePicker = document.getElementById('datePicker');
    if (datePicker) datePicker.addEventListener('change', function() {
        currentDate = datePicker.value;
        loadData(currentType, 1, currentPageSize, currentQuery, currentDate);
    });
    loadData(type, page, pageSize, query, date);
}

document.addEventListener('DOMContentLoaded', init);
