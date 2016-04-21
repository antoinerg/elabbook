require 'find'

def find(dir='/',&block)
  Find.find(dir) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == '.'
          Find.prune       # Don't look any further into this directory.
        else
          next
        end
      else
        #total_size += FileTest.size(path)
        yield(path)
      end
  end
end