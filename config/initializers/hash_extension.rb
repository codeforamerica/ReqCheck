class Hash
  def is_numeric?(s)
    !!Float(s) rescue false
  end

  def find_all_values_for(key, numeric=false)
    result = []
    result << self[key]
    self.values.each do |hash_value|
      values = [hash_value] unless hash_value.is_a? Array
      if values.nil?
        hash_value.each do |new_hash_value|
          result += new_hash_value.find_all_values_for(key) if new_hash_value.is_a? Hash
        end
      else
        values.each do |value|
          result += value.find_all_values_for(key) if value.is_a? Hash
        end
      end
    end
    if numeric
      result.compact.uniq.map{ |string| is_numeric?(string) ? string.to_i : string }
    else
      result.compact.uniq
    end
  end
end