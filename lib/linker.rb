class Linker

  Link = Struct.new(:methd, :file) do
    def exec!
      send(:methd, :file)
    end

    def xdg(file)
      puts "can exec xdg: #{file}"
    end

    def dotfile(file)
      puts "can exec dotfile: #{file}"
    end
  end

  class LinkContextMaker
    def initialize(indir, links=[], &block)
      @links = links
      @indir = indir
      instance_eval &block
    end

    def subdir(dir, &block)
      LinkContext.new(@indir, dir, @links, &block)
    end
  end

  class LinkContext
    attr_accessor :indir, :subdir

    def initialize(indir, subdir=nil, links=[], &block)
      @links = links
      @indir = indir
      @subdir = subdir
      instance_eval(&block) if block
    end

    def full_path(file)
      puts "FULL PATH: #{file}"
    end

    def method_missing(meth, *argv, &block)
      if meth && argv.size > 0
        argv.each do |file|
          @links << Link.new(meth, full_path(file))
        end
      else
        super
      end
    end
  end

  attr_accessor :links

  def initialize(linksrc)
    @links = []
    eval IO.read(linksrc)
  end

  def github(dir, &block)
    LinkContextMaker.new(dir, @links, &block)
  end

  def method_missing(methd, *argv, &block)
    puts "METHOD MISSING"
    if methd && argv.size == 2
      context = LinkContext.new(argv[0], nil, @links)
      @links << Link.new( methd, context.full_path(argv[1]) )
    else
      super
    end
  end

end
