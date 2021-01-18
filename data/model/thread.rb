require "./data/model.base.rb"

class ModelThread < ModelBase
    def initialize
        @file_dir = "./data/csv/thread.csv"
        @key_val = ["id","name"]
        setting(@file_dir,@key_val)
    end

    def fetch_filter_thread(thread_id)
        @thread_id_num = fetch_all.index {|val| val[@key_val.index("id")]==thread_id}
        if @thread_id_num
            return fetch_all[@thread_id_num]
        else
            return false
        end
    end

    def fetch_filter_thread_prev
        if @thread_id_num && @thread_id_num > 0
            return fetch_all[@thread_id_num-1]
        else
            return false
        end
    end

    def fetch_filter_thread_next
        if @thread_id_num && @thread_id_num < count-1
            return fetch_all[@thread_id_num+1]
        else
            return false
        end
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