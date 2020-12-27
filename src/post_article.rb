require "csv"

class PostArticle
    def initialize(name, article)
        data = [
            fetch_last_no + 1,
            fetch_now_unix_time,
            name!="" ? name : "名無しさん",
            article.gsub(/\R/, "\n")
        ]
        insert_data(data)
    end
    
    def fetch_last_no()
        csv = CSV.read(__dir__ + "./model/data/article.csv")
        if !csv || csv.empty?
            return 0
        end
        return csv.last[0].to_i
    end

    def insert_data(data)
        CSV.open("./model/data/article.csv","a") do |csv|
            csv << data
        end
    end

    def fetch_now_unix_time()
        return Time.now.strftime('%s%L').to_i
    end
end