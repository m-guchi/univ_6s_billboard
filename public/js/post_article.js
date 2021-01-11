$(function(){
    $("#submit-form").on("click", function () {
        const name = $('#article-form-box').find('input[name="name"]').val()
        const article = $('#article-form-box').find('textarea[name="article"]').val()
        if(article!=""){
            postArticle(name, article)
            $("#post-alert-box").html("")
        }else{
            $("#post-alert-box").html("投稿内容を入力してください")
        }
    })
})

function postArticle(name,article){
    $.ajax({
        url: 'api/article',
        type: 'POST',
        data: { name: name, article: article },
        dataType: 'json',
        timeout: 5000,
    })
    .done(function (data) {
        if(data.ok){
            successPostArticle(data.data)
        }else{
            errorPostArticle()
        }
    })
    .fail(function () {
        errorPostArticle()
    });
}

function successPostArticle(data){
    $('#article-form-box').find('input[name="name"]').val("")
    $('#article-form-box').find('textarea[name="article"]').val("")
    fetchArticle()
}

function errorPostArticle() {
    console.error("error")
}