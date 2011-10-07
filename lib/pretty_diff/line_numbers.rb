#
# Represent 2 columns of numbers that will be displayed
# on the left of the HTML presentation.
#
class PrettyDiff::LineNumbers #:nodoc:

  attr_reader :meta_info

  def initialize(meta)
    @meta_info = meta
  end

  # Increase either left column of numbers, right or both of them; depending on the Line status.
  def act_on_line(line)
    if line.added?
      increase_right
    elsif line.deleted?
      increase_left
    else
      increase_both
    end
  end

  # Generate HTML presentation for a both line numbers columns. Return a string.
  def to_html(options = {})
    PrettyDiff::LineNumbersGenerator.generate(self, options)
  end

  def left_column
    @left_column ||= []
  end

  def right_column
    @right_column ||= []
  end

private

  # Search for information about line numbers changes provided by unified diff format.
  def scan_meta(target)
    meta_info.scan(target).flatten.first
  end

  # Return starting number for the left column according to unified diff information.
  def left_starts_at
    scan_meta(/^@@ -(\d+),/).to_i
  end

  # Return starting number for the right column according to unified diff information.
  def right_starts_at
    scan_meta(/\+(\d+),\d+ @@.*?$/).to_i
  end

  # Increase left column line number by one.
  def increase_left
    left_column  << increase_or_start(:left)
    right_column << nil
  end

  # Increase right column line number by one.
  def increase_right
    left_column  << nil
    right_column << increase_or_start(:right)
  end

  # Increase both columns line numbers by one.
  def increase_both
    left_column  << increase_or_start(:left)
    right_column << increase_or_start(:right)
  end

  # Either increasing existing line number by one or using the initial number provided by
  # unified diff format.
  def increase_or_start(which)
    previous = send("#{which}_column").reverse.find{|e| !e.nil?}
    previous ? previous + 1 : send("#{which}_starts_at")
  end

end
