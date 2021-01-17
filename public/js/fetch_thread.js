const sliceNum = 10

$(function() {
    fetchThread()
    $(document).on("click", ".article-page-button", function () {
        displayThreadDOM($(this).text())
    })
})

function fetchThread() {
    $.ajax({
        url: '/api/thread',
        type: 'GET',
        dataType: 'json',
        timeout: 5000,
    })
    .done(function (data) {
        if(data.ok){
            successFetchThread(data.data)
        }else{
            errorFetch()
        }
    })
    .fail(function () {
        errorFetch()
    });
}

function successFetchThread(data) {
    allData = data.reverse() // Global変数・fetchを繰り返さないため
    displayThreadDOM()
}

function displayThreadDOM(page = 1) {
    displayThread(page)
    displayPageButton(page, allData.length)
}

function errorFetch(){
    console.error("error")
}

function displayThread(page){
    let html = ""
    data = sliceData(allData,page)
    data.forEach(function (val) {
        html += displayItem(val[0], val[1])
    })
    $("#article").html(html)
}

function displayItem(id,name) {
    return `<a class="article-item thread-item" href="/th/${id}">
                <div class="item-header">
                    <span>スレッドNo: ${id}</span>
                </div>
                <div class="thread-title">${name}</div>
            </a>`
}

function sliceData(data, page){
    return data.slice(sliceNum * (page - 1), sliceNum * page)
}

function displayPageButton(page, dataCount){
    let html = ""
    const maxPage = Math.ceil(dataCount / sliceNum)
    for (let i = 1; i < maxPage+1 ;i++){
        if(page == i){
            id = "id='article-page-active'"
        }else{
            id = ""
        }
        html += `<div class="article-page-button" ${id}>${i}</div>`
    }
    $("#article-page-box").html(html)
}