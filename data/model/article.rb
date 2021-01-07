require "./data/model.base.rb"

class ModelArticle < ModelBase
    def initialize
        @file_dir = "./data/csv/article.csv"
        @key_val = ["id","time","name","article"]
        setting(@file_dir,@key_val)
    end

    def post(name, article)
        id = fetch_last[@key_val.index("id")].to_i + 1
        time = now_unix_time()
        name = name != "" ? name : "名無しさん"
        article = article.gsub(/\R/, "\n")
        insert([id,time,name,article])
    end
end