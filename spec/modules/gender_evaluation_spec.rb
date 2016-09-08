require 'rails_helper'
require 'gender_evaluation'

RSpec.describe GenderEvaluation do
  let(:test_object) do
    class TestClass
      include GenderEvaluation
    end
    TestClass.new
  end

  let(:as_dose) { FactoryGirl.create(:antigen_series_dose) }
  describe '#evaluate_gender' do

  end

  describe '#create_gender_attributes' do
    it 'returns a hash with required_gender key and array value' do
      gender_attrs = test_object.create_gender_attributes(as_dose)
      expect(gender_attrs[:required_gender]).to eq([])
    end
    it 'returns [\'female\'] when Female included' do
      as_dose.required_gender = ['Female']

      gender_attrs = test_object.create_gender_attributes(as_dose)
      expect(gender_attrs[:required_gender]).to eq(['female'])
    end
    it 'returns [\'male\'] when Male included' do
      as_dose.required_gender = ['Male']

      gender_attrs = test_object.create_gender_attributes(as_dose)
      expect(gender_attrs[:required_gender]).to eq(['male'])
    end
    it 'returns unknown when Unknown' do
      as_dose.required_gender = ['Unknown']

      gender_attrs = test_object.create_gender_attributes(as_dose)
      expect(gender_attrs[:required_gender]).to eq(['unknown'])
    end
    it 'returns multiple values with multiple required genders ' do
      as_dose.required_gender = %w(Unknown Female)

      gender_attrs = test_object.create_gender_attributes(as_dose)
      expect(gender_attrs[:required_gender]).to eq(%w(unknown female))
    end
    it 'returns empty array when none specified' do
      expect(as_dose.required_gender).to eq([])

      gender_attrs = test_object.create_gender_attributes(as_dose)
      expect(gender_attrs[:required_gender]).to eq([])
    end
  end

  describe '#evaluate_gender_attributes' do
    describe 'with different combinations' do
      context 'with a female patient' do
        it 'returns true if the required_gender includes female' do
          gender_attrs = { required_gender: %w(female unknown) }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'female'
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
        it 'returns true if the required_gender is only female' do
          gender_attrs = { required_gender: ['female'] }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'female'
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
        it 'returns false if the required_gender doesn\'t include female' do
          gender_attrs = { required_gender: %w(male unknown) }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'female'
          )
          expect(eval_hash[:required_gender_valid]).to eq(false)
        end
        it 'returns true if the required_gender is empty' do
          gender_attrs = { required_gender: [] }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'female'
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
      end
      context 'with a male patient' do
        it 'returns true if the required_gender includes male' do
          gender_attrs = { required_gender: %w(male unknown) }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'male'
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
        it 'returns true if the required_gender is only male' do
          gender_attrs = { required_gender: ['male'] }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'male'
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
        it 'returns false if the required_gender doesn\'t include male' do
          gender_attrs = { required_gender: %w(female unknown) }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'male'
          )
          expect(eval_hash[:required_gender_valid]).to eq(false)
        end
        it 'returns true if the required_gender is empty' do
          gender_attrs = { required_gender: [] }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, 'male'
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
      end
      context 'with a patient with an unidentified gender' do
        it 'returns true if the required_gender includes unknown' do
          gender_attrs = { required_gender: %w(male unknown) }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, nil
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
        it 'returns false if the required_gender is only male' do
          gender_attrs = { required_gender: ['male'] }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, nil
          )
          expect(eval_hash[:required_gender_valid]).to eq(false)
        end
        it 'returns false if the required_gender is only female' do
          gender_attrs = { required_gender: ['female'] }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, nil
          )
          expect(eval_hash[:required_gender_valid]).to eq(false)
        end
        it 'returns true if the required_gender is empty' do
          gender_attrs = { required_gender: [] }
          eval_hash = test_object.evaluate_gender_attributes(
            gender_attrs, nil
          )
          expect(eval_hash[:required_gender_valid]).to eq(true)
        end
      end
    end
  end

  describe '#get_gender_status' do
    # This logic is defined on page 53 of the CDC logic spec
    it 'returns valid, gender, for required_gender_valid true' do
      gender_eval_hash = { required_gender_valid: true }
      expected_result = { status: 'valid',
                          evaluated: 'gender' }
      expect(test_object.get_gender_status(gender_eval_hash))
        .to eq(expected_result)
    end

    it 'returns invalid, gender, for required_gender_valid true' do
      gender_eval_hash = { required_gender_valid: false }
      expected_result = { status: 'invalid',
                          evaluated: 'gender' }
      expect(test_object.get_gender_status(gender_eval_hash))
        .to eq(expected_result)
    end
  end

  describe '#evaluate_gender ' do
    it 'takes a evaluation_antigen_series_dose, patient_gender ' \
       ' and returns a status hash' do
      as_dose.required_gender = %w(Female Unknown)
      patient_gender          = nil
      evaluation_hash = test_object.evaluate_gender(
        as_dose,
        patient_gender: patient_gender
      )
      expected_result = {
                          status: 'valid',
                          evaluated: 'gender'
                        }
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns invalid for invalid patient gender' do
      as_dose.required_gender = %w(Female Unknown)
      patient_gender          = 'male'
      evaluation_hash = test_object.evaluate_gender(
        as_dose,
        patient_gender: patient_gender
      )
      expected_result = {
                          status: 'invalid',
                          evaluated: 'gender'
                        }
      expect(evaluation_hash).to eq(expected_result)
    end
  end
end
