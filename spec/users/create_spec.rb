# frozen_string_literal: true

describe 'user creation end-point', :transaction do
  describe 'when the content-type is not application/json' do
    it 'should return 415 Unsupported Media Type' do
      header 'content-type', 'text/plain'
      post '/api/v1/users', '{}'
      expect(last_response.status).to eq(415)
      expect(last_response.body).to be_empty
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
      post_json '/api/v1/users', firstname: 'x' * 256
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
      post_json '/api/v1/users', lastname: 'x' * 256
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
    it 'should not be required' do
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:login)
    end
    it 'should be required when password is provided' do
      post_json '/api/v1/users', password: 'secret'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('must be filled')
    end
    it 'should not be too short' do
      post_json '/api/v1/users', login: '12'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('length must be within 3 - 255')
    end
    it 'should not be too long' do
      post_json '/api/v1/users', login: 'x' * 256
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('length must be within 3 - 255')
    end
    it 'should be stripped and capitalized' do
      post_json '/api/v1/users', build(:user, :with_credentials, login: " JoHn\t")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to eq('john')
    end
    context 'when there is already a user using it' do
      before(:each) do
        result = create_user.call build(:user, :with_credentials)
        expect(result).to be_success
        @user = result.value!
      end
      it 'should be unique' do
        post_json '/api/v1/users', build(:user, :with_credentials, login: @user.login)
        expect(last_response.status).to eq(409)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:login]).to eq('is already taken')
      end
    end
  end

  describe 'password' do
    it 'should not be required' do
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:password)
    end
    it 'should be required when login is provided' do
      post_json '/api/v1/users', login: 'john'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:password]).to include('must be filled')
    end
    it 'should not be too short' do
      post_json '/api/v1/users', password: '12345'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:password]).to include('size cannot be less than 6')
    end
    it 'should not be returned' do
      post_json '/api/v1/users', build(:user, :with_credentials)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:password)
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
