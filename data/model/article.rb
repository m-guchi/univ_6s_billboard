require "./data/model.base.rb"

class ModelArticle < ModelBase
    def initialize
        @file_dir = "./data/csv/article.csv"
        @key_val = ["id","thread_id","time","name","article"]
        setting(@file_dir,@key_val)
    end

    def fetch_filter_name(name)
        return fetch_all.select {|n| n[@key_val.index("name")] == name}
    end

    def fetch_filter_thread(thread_id)
        return fetch_all.select {|n| n[@key_val.index("thread_id")] == thread_id}
    end

    def post(thread_id, name, article)
        last_row = fetch_filter_thread(thread_id).last
        if last_row
            id = fetch_filter_thread(thread_id).last[@key_val.index("id")].to_i + 1
        else
            id = 1
        end
        thread_id = thread_id.to_i
        time = now_unix_time()
        name = name != "" ? name : "名無しさん"
        article = article.gsub(/\R/, "\n")
        insert([id,thread_id,time,name,article])
    end
end