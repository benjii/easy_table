module EasyTable
  module Components
    class Column
      include Base

      delegate :tag, :capture, :content_tag, :to => :@template

      def initialize(node, title, label, opts, template, block)
        @node, @title, @label, @template, @block, @opts = node, title, label, template, block, opts
        header_opts = @opts.select { |k, v| k =~ /^header_.*/ }
        header_opts.each { |k, v| @opts.delete(k) }
        @header_opts = header_opts.inject({}) do |h, e|
          k, v = *e
          h[k[7..-1]] = v
          h
        end
        @row_blocks = []
      end

      def head
        concat content_tag(:th, label, @header_opts)
      end

      def td(record)
        if @block.present?
          html = capture { @block.call(record, self) }
        else
          html = record.send(@title).to_s
        end
        concat(content_tag(:td, html, html_opts(record)))
      end

      def td_row(record, idx)
        block = @row_blocks[idx]
        html = capture { block.call }
        concat(content_tag(:td, html, html_opts(record)))
      end

      def row(&block)
        @row_blocks << block
      end

      def rowspan
        @row_blocks.size
      end

      def clear_rows
        @row_blocks = []
        @opts.delete :rowspan
      end

      def append_opt(k, v)
        @opts[k] = v
      end

      def prepare_to_render(record)
        if @block.present?
          @block_capture = capture { @block.call(record, self) }
        end
      end

      private

      def label
        @label || translate(@title)
      end

      def concat(tag)
        @template.safe_concat(tag) unless tag.nil?
        ""
      end

      def html_opts(record)
        @opts.inject({}) do |h, e|
          k, v = *e
          h[k] = case v
                   when Proc
                     v.call(record)
                   else
                     v
                 end
          h
        end
      end
    end
  end
end
