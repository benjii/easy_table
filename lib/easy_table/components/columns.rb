module EasyTable
  module Components
    module Columns
      def column(title, opts = {}, &block)
        child = node << Tree::TreeNode.new(title)
        column = Column.new(child, title, opts, @template, block)
        child.content = column
      end

      private

      def node
        @node
      end
    end
  end
end