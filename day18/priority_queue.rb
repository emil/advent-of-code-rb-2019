#frozen_string_literal: true

class PriorityQueue
  def initialize(&blk)
    @heap = [nil]
    @comparator_lambda = blk
  end

  def insert(item)
    @heap << item
    bubble_up(last_index)
    self
  end

  def next
    minimum = @heap[1]
    swap(1, last_index)
    @heap.pop
    bubble_down(1)
    minimum
  end
  alias :push :insert
  alias :pop :next

  def empty?
    @heap.size <= 1
  end

  private

  def bubble_up(index)
    parent_index = index.div 2

    return if parent_index.zero?

    child = @heap[index]
    parent = @heap[parent_index]

    if parent[0] > child[0]
      swap(index, parent_index)
      bubble_up(parent_index)
    end
  end

  def bubble_down(index)
    left_child_index = index * 2
    right_child_index = index * 2 + 1

    return if left_child_index > last_index

    lesser_child_index = determine_lesser_child(left_child_index, right_child_index)

    if compare(@heap[index], @heap[lesser_child_index]).positive?
      swap(index, lesser_child_index)
      bubble_down(lesser_child_index)
    end
  end

  def determine_lesser_child(left_child_index, right_child_index)
    return left_child_index if right_child_index > last_index

    if compare(@heap[left_child_index], @heap[right_child_index]).negative?
      left_child_index
    else
      right_child_index
    end
  end

  def last_index
    @heap.length - 1
  end

  def swap(index_a, index_b)
    @heap[index_a], @heap[index_b] = @heap[index_b], @heap[index_a]
  end

  def compare(left, right)
    if @comparator_lambda.nil?
      left <=> right
    else @comparator_lambda.call(left, right)
    end
  end
end
