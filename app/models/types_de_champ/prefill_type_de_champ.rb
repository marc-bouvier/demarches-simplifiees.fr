class TypesDeChamp::PrefillTypeDeChamp < SimpleDelegator
  POSSIBLE_VALUES_THRESHOLD = 10

  def self.build(type_de_champ)
    case type_de_champ.type_champ
    when TypeDeChamp.type_champs.fetch(:drop_down_list)
      TypesDeChamp::PrefillDropDownListTypeDeChamp.new(type_de_champ)
    else
      new(type_de_champ)
    end
  end

  def self.wrap(collection)
    collection.map { |type_de_champ| build(type_de_champ) }
  end

  def possible_values
    return [] unless prefillable?

    [I18n.t("views.prefill_descriptions.edit.possible_values.#{type_champ}_html")]
  end

  def example_value
    return nil unless prefillable?

    I18n.t("views.prefill_descriptions.edit.examples.#{type_champ}")
  end

  def too_many_possible_values?
    possible_values.count > POSSIBLE_VALUES_THRESHOLD
  end

  def possible_values_sample
    possible_values.first(POSSIBLE_VALUES_THRESHOLD)
  end
end
