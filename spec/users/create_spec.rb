# frozen_string_literal: true

describe 'user creation end-point', :transaction do
  describe 'when the content-type is not application/json' do
    it 'should return 400 Bad Request' do
      header 'content-type', 'text/plain'
      post '/api/v1/users', '{}'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:error]).to eq('expected application/json as content-type')
    end
  end
  describe 'when the request body is not JSON formated' do
    it 'should return 400 Bad Request' do
      header 'content-type', 'application/json'
      post '/api/v1/users', 'Hello'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:error]).to eq('failed to parse the request body as JSON')
    end
  end

  describe 'firstname' do
    it 'should be required' do
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('is missing')
    end
    it 'should not be empty' do
      post_json '/api/v1/users', firstname: ''
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('length must be within 1 - 255')
    end
    it 'should not be too long' do
      post_json '/api/v1/users', firstname: 'x' * 300
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('length must be within 1 - 255')
    end
    it 'should be stripped and capitalized' do
      post_json '/api/v1/users', build(:user, firstname: " john\n")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to eq('John')
    end
  end

  describe 'lastname' do
    it 'should be required' do
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('is missing')
    end
    it 'should not be empty' do
      post_json '/api/v1/users', lastname: ''
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('length must be within 1 - 255')
    end
    it 'should not be too long' do
      post_json '/api/v1/users', lastname: 'x' * 300
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('length must be within 1 - 255')
    end
    it 'should be stripped and capitalized' do
      post_json '/api/v1/users', build(:user, lastname: "\tDoE\n ")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to eq('Doe')
    end
  end

  describe 'birthdate' do
    it 'should be required' do
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include('is missing')
    end
    it 'should be a date' do
      post_json '/api/v1/users', birthdate: 'not a date'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include('must be a date')
    end
    it 'should be in the past' do
      post_json '/api/v1/users', birthdate: Date.today
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include("must be less than #{Date.today}")
    end
    it 'should be stripped and ISO8601' do
      post_json '/api/v1/users', build(:user, birthdate: " 5 Nov 1605\n")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to eq('1605-11-05')
    end
  end

  describe 'gender' do
    it 'should not be required' do
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:gender)
    end
    it 'should be either male of female' do
      post_json '/api/v1/users', gender: '?'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:gender]).to include('must be one of: female, male')
    end
    it 'should be stripped and downcased' do
      post_json '/api/v1/users', build(:user, gender: '  MALE ')
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:gender]).to eq('male')
    end
  end

  describe 'login' do
    it 'should be ignored' do
      post_json '/api/v1/users', build(:user, login: 'root')
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to be_nil
    end
  end

  describe 'id' do
    it 'should be generated' do
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).to include(:id)
    end
  end

  describe 'created_at' do
    it 'should be before now' do
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).to include(:created_at)
      created_at = DateTime.iso8601(json_body[:created_at])
      expect(created_at).to be <= DateTime.now
    end
  end

  describe 'updated_at' do
    it 'should be the same as created_at' do
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:updated_at]).to eq(json_body[:created_at])
    end
  end

  describe 'HTTP_LAST_MODIFIED' do
    it 'should be the same as updated_at' do
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(last_response.header['last-modified']).to be
      last_modified = DateTime.httpdate(last_response.header['last-modified'])
      updated_at = DateTime.iso8601(json_body[:updated_at])
      expect(last_modified).to eq(updated_at)
    end
  end
end
