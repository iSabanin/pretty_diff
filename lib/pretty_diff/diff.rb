require 'cgi'

#
# Main class to interact with. In fact this is the only class you should interact with
# when using the library.
#
# === Usage example
#  pretty = PrettyDiff::Diff.new(udiff)
#  pretty.to_html
#
# Keep in mind that Diff will automatically escape all HTML tags from the input string
# so that it doesn't interfere with the output.
#
class PrettyDiff::Diff
  CHUNK_REGEXP = /@@ .+ @@.*?\n/

  attr_reader :input

  # Create new Diff object.
  # Accept a String in unified diff format and options hash.
  def initialize(unified_diff)
    @input = escape_html(unified_diff)
  end

  # Generate HTML presentation. Return a string.
  # Current options:
  # * wrapper_class -- value of class attribute of div wrapper
  # * code_class -- value of class attribute for code div wrapper
  # * chunk_class -- value of class attribute for chunk div wrapper if chunks more then 1
  # * line_number_options -- hash of line numbers generator options.
  # * line_options -- hash of line generator options
  # * wrap_lines -- wrap each line in code block with <div> element.
  def to_html(options = {})
    PrettyDiff::DiffGenerator.generate(self, options)
  end

  # Return an array of Chunk objects that Diff found in the input.
  def chunks
    @_chunks ||= find_chunks(input)
  end

private

  # Parse the input for diff chunks and initialize a Chunk object for each of them.
  # Return an array of Chunks.
  def find_chunks(text)
    meta_info = text.scan(CHUNK_REGEXP)
    chunks = []
    chunks.tap do
      split = text.split(CHUNK_REGEXP)
      split.shift
      split.each_with_index do |lines, idx|
        chunks << PrettyDiff::Chunk.new(meta_info[idx], lines)
      end
    end
  end

  def escape_html(input_text)
    CGI.escapeHTML(input_text)
  end

end
