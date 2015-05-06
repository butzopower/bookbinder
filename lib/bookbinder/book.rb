require_relative 'git_hub_repository'
require_relative 'directory_helpers'
require_relative 'ingest/destination_directory'

module Bookbinder
  class Book
    include DirectoryHelperMethods

    def self.from_remote(logger: nil, full_name: nil, destination_dir: nil, ref: nil, git_accessor: nil)
      git_accessor.clone("git@github.com:#{full_name}",
                         Ingest::DestinationDirectory.new(full_name),
                         path: destination_dir,
                         checkout: ref)
      new(logger: logger,
          full_name: full_name,
          target_ref: ref,
          git_accessor: git_accessor)
    end

    def initialize(logger: nil,
                   full_name: nil,
                   target_ref: nil,
                   github_token: nil,
                   sections: [],
                   git_accessor: Git)
      @section_vcs_repos = sections.map do |section|
        GitHubRepository.new(logger: logger,
                             full_name: section['repository']['name'],
                             git_accessor: git_accessor)
      end

      @target_ref = target_ref || 'master'

      @repository = GitHubRepository.new(logger: logger,
                                         full_name: full_name,
                                         github_token: github_token,
                                         git_accessor: git_accessor)
      @git_accessor = git_accessor
    end

    def full_name
      @repository.full_name
    end

    def directory
      Ingest::DestinationDirectory.new(full_name)
    end

    def tag_self_and_sections_with(tag)
      (@section_vcs_repos + [@repository]).each { |repo| repo.tag_with tag }
    end

    private

    attr_reader :target_ref
  end
end
