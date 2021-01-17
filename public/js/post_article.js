$(function(){
    $("#submit-form").on("click", function () {
        const thread_id_pattern = /\/th\/(\d*)/
        const thread_id = location.pathname.match(thread_id_pattern)[1]
        const name = $('#article-form-box').find('input[name="name"]').val()
        const article = $('#article-form-box').find('textarea[name="article"]').val()
        if(article!=""){
            postArticle(thread_id, name, article)
            $("#post-alert-box").html("")
        }else{
            $("#post-alert-box").html("投稿内容を入力してください")
        }
    })
})

function postArticle(thread_id,name,article){
    
    $.ajax({
        url: '/api/article',
        type: 'POST',
        data: { thread_id: thread_id, name: name, article: article },
        dataType: 'json',
        timeout: 5000,
    })
    .done(function (data) {
        if(data.ok){
            successPostArticle(data.data, thread_id)
        }else{
            errorPostArticle()
        }
    })
    .fail(function () {
        errorPostArticle()
    });
}

function successPostArticle(data, thread_id){
    $('#article-form-box').find('input[name="name"]').val("")
    $('#article-form-box').find('textarea[name="article"]').val("")
    fetchArticle(thread_id)
}

function errorPostArticle() {
    console.error("error")
}