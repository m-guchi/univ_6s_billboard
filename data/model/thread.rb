require "./data/model.base.rb"

class ModelThread < ModelBase
    def initialize
        @file_dir = "./data/csv/thread.csv"
        @key_val = ["id","name"]
        setting(@file_dir,@key_val)
    end

    def fetch_filter_thread?(thread_id)
        return fetch_all.find {|val| val[0]==thread_id}
    end

    def post(name)
        random = Random.new
        loop do
            id = ((random.rand)*(10**8)).round
            unless fetch_filter_colum("id").include?(id)
                name = name != "" ? name : ""
                return insert([id,name])
            end
        end
    end
end