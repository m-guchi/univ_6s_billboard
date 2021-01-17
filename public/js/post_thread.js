$(function(){
    $("#submit-form").on("click", function () {
        const name = $('#article-form-box').find('input[name="name"]').val()
        if(name!=""){
            postThread(name)
            $("#post-alert-box").html("")
        }else{
            $("#post-alert-box").html("スレッドタイトルを入力してください")
        }
    })
})

function postThread(name){
    $.ajax({
        url: '/api/thread',
        type: 'POST',
        data: { name: name },
        dataType: 'json',
        timeout: 5000,
    })
    .done(function (data) {
        if(data.ok){
            successPostThread(data.data)
        }else{
            errorPost()
        }
    })
    .fail(function () {
        errorPost()
    });
}

function successPostThread(data){
    $('#article-form-box').find('input[name="name"]').val("")
    window.location.href = "/th/" + data[0];
}

function errorPost() {
    console.error("error")
}