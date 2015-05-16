# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class Tree
  attr_accessor :right, :left, :data
  def initialize(data)
    @data = data
  end
  def add_child(value)
    case @data <=> value.data 
    when 1 then  @right == nil ? @right = value : right.add_child(value)
    else @left == nil ? @left = value : left.add_child(value)
    end
  end
  def print_tree
    @right.print_tree if @right != nil
    puts @data
    @left.print_tree if @left != nil
  end
end

a = Tree.new(10)
b = Tree.new(1)
c = Tree.new(15)
d = Tree.new(20)
a.add_child(b)
a.add_child(c)
a.add_child(d)
a.print_tree