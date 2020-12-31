require "csv"

class ModelBase
    @@file_dir = String.new

    def initialize
        @@csv_data = CSV.read(@@file_dir)
    end

    def fetch_all
        return @@csv_data[1..-1]
    end

    def fetch_last
        return fetch_all.last
    end

    def count
        return fetch_all.length
    end

    def fetch_colum
        return @@csv_data[0]
    end

    def colum_count
        return fetch_colum.length
    end

    def insert(data)
        if data.length == colum_count
            CSV.open(@@file_dir,"a") do |csv|
                csv << data
            end
            return true
        else
            return false
        end
    end
    
    def now_unix_time
        return Time.now.strftime('%s%L').to_i
    end
end