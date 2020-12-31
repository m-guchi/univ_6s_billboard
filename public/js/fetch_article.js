$(function() {
    fetchArticle();
})

function fetchArticle() {
    $.ajax({
        url: 'api/article',
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
    let html = ""
    data.reverse()
    data.forEach(function(val){
        let dateTime = new Date(Number(val[1]))
        let time = dateTime.toLocaleDateString('ja-JP')
        time += "(" + ["日", "月", "火", "水", "木", "金", "土"][dateTime.getDay()] + ") "
        time += dateTime.toLocaleTimeString('ja-JP')
        const text = val[3].replace(/\n/g, "</br>")
        html += displayItem(val[0], val[2], time, text)
    })
    $("#article").html(html)
}

function errorFetchArticle(){
    console.error("error")
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