# frozen_string_literal: true

describe 'user creation end-point', :transaction do
  before(:each) do
    creation = create_user build(:user, :with_credentials)
    expect(creation).to be_success
    @current_user = creation.value!
    encoding = tokenize @current_user
    expect(encoding).to be_success
    @token = encoding.value!
  end

  describe 'firstname' do
    it 'should be required' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('is missing')
    end
    it 'should not be empty' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', firstname: ''
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('length must be within 1 - 255')
    end
    it 'should not be too long' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', firstname: 'x' * 256
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('length must be within 1 - 255')
    end
    it 'should be stripped and capitalized' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user, firstname: " john\n")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to eq('John')
    end
  end

  describe 'lastname' do
    it 'should be required' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('is missing')
    end
    it 'should not be empty' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', lastname: ''
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('length must be within 1 - 255')
    end
    it 'should not be too long' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', lastname: 'x' * 256
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('length must be within 1 - 255')
    end
    it 'should be stripped and capitalized' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user, lastname: "\tDoE\n ")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to eq('Doe')
    end
  end

  describe 'birthdate' do
    it 'should be required' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include('is missing')
    end
    it 'should be a date' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', birthdate: 'not a date'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include('must be a date')
    end
    it 'should be in the past' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', birthdate: Date.today
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include("must be less than #{Date.today}")
    end
    it 'should be stripped and ISO8601' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user, birthdate: " 5 Nov 1605\n")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to eq('1605-11-05')
    end
  end

  describe 'gender' do
    it 'should not be required' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:gender)
    end
    it 'should be either male of female' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', gender: '?'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:gender]).to include('must be one of: female, male')
    end
    it 'should be stripped and downcased' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user, gender: '  MALE ')
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:gender]).to eq('male')
    end
  end

  describe 'login' do
    it 'should not be required' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:login)
    end
    it 'should be required when password is provided' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', password: 'secret'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('must be filled')
    end
    it 'should not be too short' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', login: '12'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('length must be within 3 - 255')
    end
    it 'should not be too long' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', login: 'x' * 256
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('length must be within 3 - 255')
    end
    it 'should be stripped and capitalized' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user, :with_credentials, login: " JoHn\t")
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to eq('john')
    end
    it 'should be unique' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user, :with_credentials, login: @current_user.login)
      expect(last_response.status).to eq(409)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to eq('is already taken')
    end
  end

  describe 'password' do
    it 'should not be required' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', {}
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:password)
    end
    it 'should be required when login is provided' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', login: 'john'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:password]).to include('must be filled')
    end
    it 'should not be too short' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', password: '12345'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:password]).to include('size cannot be less than 6')
    end
    it 'should not be returned' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user, :with_credentials)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:password)
    end
  end

  describe 'id' do
    it 'should be generated' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).to include(:id)
    end
  end

  describe 'version' do
    it 'should be generated' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).to include(:version)
    end
  end

  describe 'created_at' do
    it 'should be before now' do
      header 'authorization', "Bearer #{@token}"
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
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:updated_at]).to eq(json_body[:created_at])
    end
  end

  describe 'HTTP_ETAG' do
    it 'should be the same as version' do
      header 'authorization', "Bearer #{@token}"
      post_json '/api/v1/users', build(:user)
      expect(last_response.status).to eq(201)
      expect(last_response.content_type).to eq('application/json')
      expect(last_response.header['etag']).to match(json_body[:version])
    end
  end
end
