require 'rails_helper'

RSpec.describe CommentaireHelper, type: :helper do
  describe ".commentaire_is_from_me_class" do
    let(:commentaire) { create(:commentaire, email: "michel@pref.fr") }

    subject { commentaire_is_from_me_class(commentaire, me) }

    context "when commentaire is from me" do
      let(:me) { "michel@pref.fr" }

      it { is_expected.to eq("from-me") }
    end

    context "when commentaire is not from me" do
      let(:me) { "roger@usager.fr" }

      it { is_expected.to eq nil }
    end
  end

  describe '.commentaire_date' do
    let(:present_date) { Time.local(2018, 9, 2, 10, 5, 0) }
    let(:creation_date) { present_date }
    let(:commentaire) do
      Timecop.freeze(creation_date) { create(:commentaire, email: "michel@pref.fr") }
    end

    subject do
      Timecop.freeze(present_date) { commentaire_date(commentaire) }
    end

    it 'doesn’t include the creation year' do
      expect(subject).to eq 'le 2 septembre à 10 h 05'
    end

    context 'when displaying a commentaire created on a previous year' do
      let(:creation_date) { present_date.prev_year }
      it 'includes the creation year' do
        expect(subject).to eq 'le 2 septembre 2017 à 10 h 05'
      end
    end

    context 'when formatting the first day of the month' do
      let(:present_date) { Time.local(2018, 9, 1, 10, 5, 0) }
      it 'includes the ordinal' do
        expect(subject).to eq 'le 1er septembre à 10 h 05'
      end
    end
  end
end
