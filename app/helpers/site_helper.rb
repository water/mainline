# encoding: utf-8

module SiteHelper
  def recent_event_timestamp(time)
    distance = Time.now - time

    human_distance = case distance
    when 0..3599
      "#{distance.ceil / 60} min."
    else
      "#{distance.ceil / 60 / 60} h."
    end
  end

  # Inserting wbr tags on colons and slashes for the recent events so that
  # it word breaks prettier.
  def word_break_recent_event_actions(text)
    text.gsub(/<a([^>]+)>([^<]+)/) {
      tag_attributes = $~[1]
      to_break = $~[2]
      
      word_broken = to_break.gsub(/\/|\:/) { $~[0] + "<wbr>" }
      %{<a#{tag_attributes}>#{word_broken}}
    }
  end
end
