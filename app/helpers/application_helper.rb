module ApplicationHelper

  def nav_data(arr)
    fin = []
    arr.each_with_index do |data, i|
      value = @entry["#{data}"] if @entry["#{data}"]
      value = @entry.video["#{data}"] if @entry.video["#{data}"]
      st = nav_label(data, value, i)
      fin.push(st) unless value == 0
    end
    fin = fin.join
    fin
  end

  def nav_comments(arr)
    fin = []
    arr.each_with_index do |comment|
      st = nav_label(comment.author.name, comment.content, i, "centernavdata")
      fin.push(st)
    end
    fin
  end

  def nav_label(label, value, i, identifier="navdata")
    label = label.to_s.humanize
    label = label.gsub("Fb", "Facebook")
    value = number_with_delimiter(value) if value.numeric?
    value = "#{time_ago_in_words(value)} ago" if value.class == Time
    label = label.gsub("at", "")
    st = "<li class='hide' id='#{identifier}_#{i+1}'><a href='#'><b>#{label}</b> #{value}</a></li>"  
    st
  end

end
