module LinksOrganizer
  def add_links(temp_file, links_file)
    File.open(links_file, "a") do |new|
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

  def unify_links(links_file)
    orig_links = orig_other_links_uniq(links_file) + orig_facebook_links_uniq(links_file)

    File.open(links_file, "w") do |new|
      orig_links.each{ |line| new.puts line }
    end
  end

  private

  def orig_facebook_links_uniq(links_file)
    all_lines =
      File.open(links_file, "r")
        .map{ |line|
          /.+https?:\/\/l.facebook.com\/l.php\?u=\S+&h=/.match(line)
            .to_s
            .gsub(/https?:\/\/l.facebook.com\/l.php\?u=|&h=/,
              /https?:\/\/l.facebook.com\/l.php\?u=/ => "",
              "&h=" => "]"
            )}
        .compact
        .uniq
        .reject(&:empty?)

    all_lines.map!{ |line| URI.decode(line) }
  end

  def orig_other_links_uniq(links_file)
    all_lines =
      File.open(links_file, "r")
        .map{ |line|
          line if /\[.+ http\S+/.match(line)
        }.reject{ |line|
          /\[.+ https?:\/\/l.facebook.com\/l.php\S+/.match(line)
        }
        .compact
        .uniq
  end
end
