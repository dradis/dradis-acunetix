module Acunetix
  module Cleanup
    private

    # Convert HTML in the text to Textile format
    def cleanup_html(source)
      result = source.dup

      format_table(result)
      result = format_list(result)

      result.gsub!(/&quot;/, '"')
      result.gsub!(/&amp;/, '&')
      result.gsub!(/&lt;/, '<')
      result.gsub!(/&gt;/, '>')

      result.gsub!(/<h[0-9] >(.*?)<\/h[0-9]>/) { "\n\n*#{$1.strip}*\n\n" }
      result.gsub!(/<b>(.*?)<\/b>/) { "*#{$1.strip}*" }
      result.gsub!(/<br\/>/, "\n")
      result.gsub!(/<div(.*?)>|<\/div>/, '')
      result.gsub!(/<a.*?>(.*?)<\/a>/m, '\1')
      result.gsub!(/<font.*?>(.*?)<\/font>/m, '\1')
      result.gsub!(/<h2>(.*?)<\/h2>/) { "*#{$1.strip}*" }
      result.gsub!(/<i>(.*?)<\/i>/, '\1')
      result.gsub!(/<p.*?>(.*?)<\/p>/) { "\np. #{$1.strip}\n" }
      result.gsub!(/<code><pre.*?>(.*?)<\/pre><\/code>/m){|m| "\n\nbc.. #{$1.strip}\n\np.  \n" }
      result.gsub!(/<code>(.*?)<\/code>/) { "@#{$1.strip}@" }
      result.gsub!(/<pre.*?>(.*?)<\/pre>/m){|m| "\n\nbc.. #{$1.strip}\n\np. \n" }

      result.gsub!(/<li.*?>([\s\S]*?)<\/li>/m){"\n* #{$1}"}
      result.gsub!(/<ul>([\s\S]*?)<\/ul>/m){ "#{$1}\n" }
      result.gsub!(/(<ul>)|(<\/ul>|(<ol>)|(<\/ol>))/, "\n")
      result.gsub!(/<li>/, "\n* ")
      result.gsub!(/<\/li>/, "\n")

      result.gsub!(/<strong>(.*?)<\/strong>/) { "*#{$1.strip}*" }
      result.gsub!(/<span.*?>(.*?)<\/span>/m){"#{$1.strip}\n"}
      result.gsub!(/<span.*?>|<\/span>/, '') #repeating again to deal with nested/empty/incomplete span tags
      result.gsub!(/(&#x\d{0,3};)/m) { "==#{$1.strip}==" }

      # Cleanup lingering <p></p>
      result.gsub!(/<p.*?>(.*?)<\/p>/m) { $1 }

      result
    end

    # Replace periods for commas as decimals
    def cleanup_decimals(source)
      result = source.dup
      result.gsub!(/([0-9])\,([0-9])/, '\1.\2')
      result
    end

    def format_list(str)
        return str unless str.include?('</ul>') || str.include?('</ol>')
        deep = 0
        text = str.split(/<(?<tag>\/?(ul|ol|li)).*?>/)
        result = ""
        text.each do |string|
            string.strip!
            if (string == 'ul' || string == 'ol')
                deep = deep + 1
            elsif (string == '/ul' || string == '/ol')
                deep = deep - 1
            elsif (string == 'li')
                result += "".ljust(deep, "*")
            elsif (string != '/li' && string.strip != "")
                result += " " + string + "\n"
            end
        end
        return result
    end

    def format_table(str)
      return unless str.include?('</table>')

      str.gsub!(/<table.*?>[\s\S]*<\/table>/) do |table|
        rows = ['']

        table.scan(/<tr>[\s\S]*?<\/tr>/).each do |tr|
          row = '|'

          tr.scan(/<td.*?>[\s\S]*?<\/td>/).each do |data|
            header = rows.empty? ? '_. ' : ''
            row << "#{header}#{data.gsub(/<td.*?>|<\/td>/, '')}|"
          end

          rows << row
        end

        rows.join("\n")
      end
    end

    # Some of the values have embedded HTML conent that we need to strip
    def tags_with_html_content
      [:details, :description, :detailed_information, :impact, :recommendation]
    end

    def tags_with_commas
      [:cvss3_score, :cvss3_tempscore, :cvss3_envscore]
    end
  end
end
