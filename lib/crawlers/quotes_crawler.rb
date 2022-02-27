module Crawlers
    class QuotesCrawler

        ## Fetch the quotes from the website if they're not in cache
        def request_quotes(tag)

            begin
                
                #Check if tag is in cache
                tr = TagRequest.find_by(tag:tag)

                #If so, check if its not too old
                return tr.date + 1.week > DateTime.now

            rescue Mongoid::Errors::DocumentNotFound => e
                puts e
            end
   
            # If the tag wasn't searched yet or the last request is too old, then...
            request_quotes_recursively(tag)
        end

        private

        BASE_URL = "http://quotes.toscrape.com/"

        ## Fetch the quotes from the website
        def request_quotes_recursively(tag, page_num = 1)
        
            # Loads page data from the internet
            page = request_website(tag, page_num)
    
            # Stop condition: page couldn't be fetched
            return if page.nil?

            # Looking for quotes in the page
            quotes = page.search(:'.quote');

            # Stop condition: no quotes in this page
            return if quotes.length == 0 

            # Scrap and save quotes
            scrap_and_save(quotes, tag, page_num)
           
            # Repeat with next page
            return request_quotes_recursively(tag, page_num + 1)
            
        end

        def scrap_and_save(quotes, tag, page_num)
            quotes.each do |q| 
                
                quote = Quote.new()
                quote.quote = q.at(:'.text').text.delete_prefix('“').delete_suffix('”')
                quote.id = hash_quote(quote.quote)

                # Don't save a quote if it is already in db
                next if quote_exists?(quote.id) 

                quote.author = q.at(:'.author').text
                quote.author_about = BASE_URL.delete_suffix('/') + q.at(:a).attr(:href)
                quote.tags = q.at(:'.tags').search(:'.tag').map{|t| t.text}
                
                quote.save

            end

            if page_num == 1
                save_request(tag)
            end
        end

        ## Saves a request by a tag in cache
        def save_request(tag)
            tr = TagRequest.where(tag: tag).first_or_initialize 
            tr.date = DateTime.now
            tr.save
        end

        def quote_exists?(quote_hash)
            begin
                Quote.find_by(id: quote_hash)
                true
            rescue Mongoid::Errors::DocumentNotFound 
                false
            end
        end

        def request_website(tag, page_num)
            begin
                url = "#{BASE_URL}tag/#{tag}/page/#{page_num}"
                return Nokogiri::HTML(HTTParty.get(url).body)
            rescue
                return nil
            end
        end

        ## Creates an id for a quote to increase db search performance
        def hash_quote(quote)
            Digest::SHA1.hexdigest quote
        end
    end
end 