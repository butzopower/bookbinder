module Bookbinder
  module Preprocessing
    class CopyToSiteGenDir
      def initialize(filesystem)
        @filesystem = filesystem
      end

      def preprocess(sections, output_locations)
        sections.each do |section|
          filesystem.copy_contents(
            section.path_to_repository,
            output_locations.source_for_site_generator.join(section.desired_directory)
          )
        end
      end

      private

      attr_reader :filesystem
    end
  end
end
