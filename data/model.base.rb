require "csv"

class ModelBase
    def setting(file_dir, key_val)
        @file_dir = file_dir
        @key_val = key_val
        unless File.exist?(file_dir)
            create_csv_file(file_dir)
        end
        @csv_data = CSV.read(file_dir)
    end

    def fetch_all
        return @csv_data[1..-1]
    end

    def fetch_last
        return fetch_all.last || 0
    end

    def count
        return fetch_all.length
    end

    def fetch_colum
        return @csv_data[0]
    end

    def colum_count
        return fetch_colum.length
    end

    def insert(data)
        if data.length == colum_count
            CSV.open(@file_dir,"a") do |csv|
                csv << data
            end
        end
    end
    
    def now_unix_time
        return Time.now.strftime('%s%L').to_i
    end

    def create_csv_file(file_dir)
        CSV.open(file_dir, 'w') do |csv|
            csv << @key_val 
        end
    end
end