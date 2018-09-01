module LinksOrganizer
  def unify_links(temp_file, links_file)
    File.open(links_file, "w") do |new|
      old_file_lines = []
      File.open(temp_file, "r") do |old|
        old.each_line do |line|
          old_file_lines << line
        end
      end
      old_file_lines.uniq.each do |line|
        new.puts line
      end
      File.delete(temp_file)
    end
  end
end
