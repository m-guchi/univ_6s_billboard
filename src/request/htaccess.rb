class Htaccess
    def initialize(path)
        @path = path.dup # 破壊的変更(pop)あるため
        @htaccess = Hash.new()
        @header_hash = Hash.new()
        check_htaccess_file()
    end

    def check_htaccess_file()
        loop do
            unless @path.pop
                break
            end
            if @path.empty?
                file_path = "./public/.htaccess"
            else
                file_path = "./public/" + @path.join("/") + "/.htaccess"
            end
            if File.exist?(file_path)
                file = File.open(file_path)
                s = file.readlines
                file.close
                s.each do |line|
                    line = line.chomp
                    arr = line.split
                    key = arr.shift
                    unless @htaccess.key?(key) # 上書きしない
                        @htaccess[key] = arr
                    end
                end
            end
        end
    end
    private:check_htaccess_file

    def hash
        return @htaccess
    end

    def has_key?(key)
        return @htaccess.key?(key)
    end

    def redirect?
        return hash["R"][1] != nil
    end

    def rewrite # R
        (path, code) = hash["R"]
        if redirect?
            # 外部転送(リダイレクト)
            status_code = code.to_i
            if status_code.div(100) == 3
                # status_codeが300番台であるか
                @status_code = status_code
                @header_hash["Location"] = path
            else
                @status_code = 500
            end
        else
            # 内部転送
            @paths = split_path(path)
        end
    end

    def status_code
        return @status_code
    end
    def header_hash
        return @header_hash
    end
    def paths
        return @paths
    end

    def split_path(path)
        if path == ""
            path = "/"
        end
        if path.end_with?("/")
            path += "index"
        end
        if path.slice(0) == "/"
            path[0] = ""
        end
        paths = path.split("/")
        return paths || nil
    end
    private:split_path
end