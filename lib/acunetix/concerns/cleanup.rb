module Cleanup
  private

  # Convert HTML in the text to Textile format
  def cleanup_html(source)
    result = source.dup
    result.gsub!(/&quot;/, '"')
    result.gsub!(/&amp;/, '&')
    result.gsub!(/&lt;/, '<')
    result.gsub!(/&gt;/, '>')

    result.gsub!(/<b>(.*?)<\/b>/) { "*#{$1.strip}*" }
    result.gsub!(/<br\/>/, "\n")
    result.gsub!(/<font.*?>(.*?)<\/font>/m, '\1')
    result.gsub!(/<h2>(.*?)<\/h2>/) { "*#{$1.strip}*" }
    result.gsub!(/<i>(.*?)<\/i>/, '\1')
    result.gsub!(/<p>(.*?)<\/p>/) { "p. #{$1.strip}\n" }
    result.gsub!(/<code><pre.*?>(.*?)<\/pre><\/code>/m){|m| "\n\nbc.. #{$1.strip}\n\np.  \n" }
    result.gsub!(/<pre.*?>(.*?)<\/pre>/m){|m| "\n\nbc.. #{$1.strip}\n\np.  \n" }
    result.gsub!(/<ul>(.*?)<\/ul>/m){"#{$1.strip}\n"}

    result.gsub!(/<li>(.*?)<\/li>/){"\n* #{$1.strip}"}

    result.gsub!(/<strong>(.*?)<\/strong>/) { "*#{$1.strip}*" }
    result.gsub!(/<span.*?>(.*?)<\/span>/m){"#{$1.strip}\n"} 

    result
  end

  # Replace periods for commas as decimals
  def cleanup_decimals(source)
    result = source.dup
    result.gsub!(/([0-9])\,([0-9])/, '\1.\2')
    result
  end

  # Some of the values have embedded HTML conent that we need to strip
  def tags_with_html_content
    [:details, :description, :detailed_information, :impact, :recommendation]
  end

  def tags_with_commas
    [:cvss3_score, :cvss3_tempscore, :cvss3_envscore]
  end
end
