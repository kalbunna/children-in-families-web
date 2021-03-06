require 'spec_helper'

RSpec.describe Api::V1::CaseNotesController, type: :request do
  let(:user) { create(:user) }
  let!(:client) { create(:client, user: user) }
  let(:assessment) { create(:assessment) }
  let!(:assessment_domain) { create_list(:assessment_domain, 12, assessment: assessment) }
  let!(:tasks) { create_list(:task, 2, case_note_domain_group: nil, domain: Domain.first) }

  describe 'POST #create' do
    context 'when user not loged in' do
      before do
        post "/api/v1/clients/#{client.id}/assessments"
      end

      it 'should be return status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user loged in' do
      before do
        sign_in(user)
        @domain_group = DomainGroup.all.sample
      end

      context 'when try to create case note with incompleted tasks' do
        before do
          case_note = { format: 'json', case_note: { meeting_date: Time.now, attendee: FFaker::Name.name, case_note_domain_groups_attributes: [{note: FFaker::Lorem.paragraph, domain_group_id: @domain_group.id}] } }
          post "/api/v1/clients/#{client.id}/case_notes", case_note, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when try to create case note with completed task' do
        before do
          case_note = { format: 'json', case_note: { meeting_date: Time.now, attendee: FFaker::Name.name, case_note_domain_groups_attributes: [{note: FFaker::Lorem.paragraph, domain_group_id: @domain_group.id, task_ids: tasks.map(&:id)}] } }
          post "/api/v1/clients/#{client.id}/case_notes", case_note, @auth_headers
        end

        it 'should be return status 200' do
          expect(response).to have_http_status(:success)
        end

        it 'should be update tasks' do
          expect(Task.first.completed).to be true
        end
      end

      context 'when try to create case note without domain group' do
        before do
          case_note = { format: 'json', case_note: { meeting_date: Time.now, attendee: FFaker::Name.name, case_note_domain_groups_attributes: [{note: FFaker::Lorem.paragraph}] } }
          post "/api/v1/clients/#{client.id}/case_notes", case_note, @auth_headers
        end

        it 'should be return status 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should be return validation message' do
          expect(json['case_note_domain_groups.domain_group']).to eq ['can\'t be blank']
        end
      end
    end
  end
end
