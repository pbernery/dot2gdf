#!/usr/bin/env ruby
#
# Transform a .dot file to a .gdf file

if ARGV.count < 1
  puts 'usage: dot2gdf <dot file>'
  exit
end

# A Node
class Node
  attr_accessor :name, :title, :path
  attr_accessor :to_count, :from_count

  def group
    components = path.split('/')
    components.count > 1 ? components[1] : '<no group found>'
  end

  def to_s
    "#{name},#{path},'#{title}',#{from_count},#{to_count},#{group}"
  end
end

# An Edge
class Edge
  attr_accessor :source, :target

  def to_s
    "#{source},#{target},true,1.0"
  end
end

# Parse a .dot file and creates Nodes and Edges.
class Parser
  attr_reader :nodes
  attr_reader :edges

  def initialize(file)
    @file = file
  end

  def parse
    states = %i(initial node edge finished)
    state = states.first

    @nodes = []
    @edges = []
    @source_count = {}
    @target_count = {}

    File.readlines(@file).each do |line|
      case state
      when :initial
        if node_line?(line)
          state = :node
          @nodes << node(line)
        end
      when :node
        if node_line?(line)
          @nodes << node(line)
        else
          state = :edge
          @edges << edge(line)
        end
      when :edge
        if edge_line?(line)
          @edges << edge(line)
        else
          state = :finished
        end
      end
    end

    @nodes.each do |n|
      n.to_count = @target_count[n.name]
      n.from_count = @source_count[n.name]
    end
  end

  private

  def node_line?(line)
    line =~ /.*\[label = .*/
  end

  def node(line)
    matched = /([^ ]*) \[label = "(.*)\\n(.*)"\];/.match(line)
    node = Node.new
    node.name = matched[1]
    node.title = matched[2]
    node.path = matched[3]
    node
  end

  def edge_line?(line)
    line =~ /.* -> .*/
  end

  def edge(line)
    matched = /([^ ]*) -> ([^ ]*)\n/.match(line)
    edge = Edge.new
    edge.source = matched[1]
    edge.target = matched[2]
    update_counts(edge)
    edge
  end

  def update_counts(edge)
    update_count(@source_count, edge.source)
    update_count(@target_count, edge.target)
  end

  def update_count(hash, id)
    if hash.key?(id)
      hash[id] += 1
    else
      hash[id] = 1
    end
  end
end

# Exports nodes and edges.
class Exporter
  def initialize(nodes, edges)
    @nodes = nodes
    @edges = edges
  end

  def to_screen
    puts nodedef
    @nodes.each { |n| puts n.to_s }
    puts edgedef
    @edges.each { |e| puts e.to_s }
  end

  private

  def nodedef
    'nodedef>name VARCHAR,path VARCHAR,title VARCHAR,from_count INTEGER,to_count INTEGER,group VARCHAR'
  end

  def edgedef
    'edgedef>node1 VARCHAR,node2 VARCHAR,directed BOOLEAN,cardinal DOUBLE'
  end
end

parser = Parser.new(ARGV[0])
parser.parse
exporter = Exporter.new(parser.nodes, parser.edges)
exporter.to_screen
