const sliceNum = 20

$(function() {
    fetchArticle()
    $(document).on("click", ".article-page-button", function () {
        displayDOM($(this).text())
    })
})

function fetchArticle() {
    const pattern = /\/th\/(\d*)/
    const thread_id = location.pathname.match(pattern)[1]
    $.ajax({
        url: '/api/article?thread=' + thread_id,
        type: 'GET',
        dataType: 'json',
        timeout: 5000,
    })
    .done(function (data) {
        if(data.ok){
            successFetchArticle(data.data)
        }else{
            errorFetchArticle()
        }
    })
    .fail(function () {
        errorFetchArticle()
    });
}

function successFetchArticle(data) {
    allData = data.reverse() // Global変数・fetchを繰り返さないため
    displayDOM()
}

function displayDOM(page = 1) {
    displayArticle(page)
    displayPageButton(page, allData.length)
}

function errorFetchArticle(){
    console.error("error")
}

function displayArticle(page){
    let html = ""
    data = sliceData(allData,page)
    data.forEach(function (val) {
        let dateTime = new Date(Number(val[2]))
        let time = dateTime.toLocaleDateString('ja-JP')
        time += "(" + ["日", "月", "火", "水", "木", "金", "土"][dateTime.getDay()] + ") "
        time += dateTime.toLocaleTimeString('ja-JP')
        const text = val[4].replace(/\n/g, "</br>")
        html += displayItem(val[0], val[3], time, text)
    })
    $("#article").html(html)
}

function displayItem(id,name,time,text) {
    return `<div class="article-item">
            <div class="item-header">
                <span class="item-number">${id}</span>
                <span>名前:</span>
                <span class="item-name">${name}</span>
                <span>${time}</span>
            </div>
            <div class="item-text">${text}</div>
        </div>`
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