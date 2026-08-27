# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module StratifiedSortitions
    # Seeds a demo component with usable stratified sortitions.
    #
    # This previously created only the Decidim::Component, mirroring
    # Decidim::Sortitions::Seeds. For this module that leaves the component empty, because a
    # stratified sortition is only meaningful once it has strata and substrata -- without them
    # `StratifiedSortition#strata_and_substrata_configured?` is false and the sortition cannot
    # be executed at all. So the seed also builds a realistic stratification.
    #
    # Note the component.seeds registration in component.rb: without it Decidim.seed! never
    # calls this class, and the module stays completely empty after a full seed run.
    #
    # Content here is deliberately deterministic rather than Faker-generated. Strata like
    # "Gender" or "Age group" have to be human-meaningful for the sortition to demonstrate
    # anything, and random words would make the quotas nonsense.
    class Seeds
      attr_reader :participatory_space

      # Demographic strata of the kind a real citizens' assembly is drawn against.
      # `kind` must be one of Stratum::KINDS ("value" or "numeric_range").
      # Quotas are percentages and sum to 100 within each stratum.
      STRATA = [
        { name: "Gender", kind: "value",
          substrata: [["Woman", 50], ["Man", 48], ["Non-binary", 2]] },
        { name: "Age group", kind: "numeric_range",
          substrata: [["16-29", 22], ["30-44", 26], ["45-64", 32], ["65+", 20]] },
        { name: "Territory", kind: "value",
          substrata: [["Barcelona", 40], ["Girona", 15], ["Lleida", 12],
                      ["Tarragona", 18], ["Terres de l'Ebre", 15]] },
        { name: "Education", kind: "value",
          substrata: [["Primary", 25], ["Secondary", 40], ["Higher", 35]] }
      ].freeze

      SORTITIONS = [
        { title: "Citizens' Assembly on Climate Adaptation",
          num_candidates: 60,
          criteria: "Stratified random selection across gender, age, territory and education.",
          profiles: "A panel mirroring the demographic distribution of the population." },
        { title: "Deliberative Panel on Housing Policy",
          num_candidates: 40,
          criteria: "LEXIMIN fair selection maximising the minimum selection probability.",
          profiles: "Forty residents balanced across the four strata." }
      ].freeze

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!
        SORTITIONS.each { |attributes| create_sortition!(component:, attributes:) }
        component
      end

      private

      def locales
        @locales ||= participatory_space.organization.available_locales.map(&:to_s)
      end

      # Decidim stores translatable columns as jsonb keyed by locale.
      def translated(text)
        locales.index_with { text }
      end

      def create_component!
        Decidim::Component.create!(
          name: Decidim::Components::Namer.new(
            participatory_space.organization.available_locales, :stratified_sortitions
          ).i18n_name,
          manifest_name: :stratified_sortitions,
          published_at: Time.current,
          participatory_space:
        )
      end

      def create_sortition!(component:, attributes:)
        sortition = Decidim::StratifiedSortitions::StratifiedSortition.create!(
          component:,
          title: translated(attributes[:title]),
          description: translated("<p>#{attributes[:criteria]}</p>"),
          num_candidates: attributes[:num_candidates],
          selection_criteria: translated(attributes[:criteria]),
          selected_profiles_description: translated(attributes[:profiles])
        )

        STRATA.each_with_index do |stratum_attributes, index|
          create_stratum!(sortition:, attributes: stratum_attributes, position: index)
        end

        sortition
      end

      def create_stratum!(sortition:, attributes:, position:)
        stratum = Decidim::StratifiedSortitions::Stratum.create!(
          stratified_sortition: sortition,
          name: translated(attributes[:name]),
          kind: attributes[:kind],
          position:
        )

        attributes[:substrata].each_with_index do |(label, quota), index|
          Decidim::StratifiedSortitions::Substratum.create!(
            stratum:,
            name: translated(label),
            value: translated(label),
            # `range` only carries meaning for numeric_range strata.
            range: (attributes[:kind] == "numeric_range" ? label : nil),
            max_quota_percentage: quota,
            position: index
          )
        end

        stratum
      end
    end
  end
end
