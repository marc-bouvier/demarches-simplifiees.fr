class Dossiers::BatchOperationComponent < ApplicationComponent
  attr_reader :statut, :procedure

  def initialize(statut:, procedure:)
    @statut = statut
    @procedure = procedure
  end

  def render?
    @statut == 'traites' || 'suivis'
  end

  def available_operations
    options = []
    case @statut
    when 'traites' then
      options.push [t(".operations.archiver"), BatchOperation.operations.fetch(:archiver)]
    when 'suivis' then
      options.push [t(".operations.passer_en_instruction"), BatchOperation.operations.fetch(:passer_en_instruction)]
    else
    end
    options
  end
end
