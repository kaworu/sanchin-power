# frozen_string_literal: true

describe 'users update end-point', :transaction do
  before(:each) do
    creation = create_user build(:user, :with_credentials)
    expect(creation).to be_success
    @current_user = creation.value!
    encoding = tokenize @current_user
    expect(encoding).to be_success
    @token = encoding.value!
  end

  before(:each) do
    result = create_user build(:user, firstname: 'jane')
    expect(result).to be_success
    @jane = result.value!
  end

  context 'when given malformed id' do
    it 'should return 404 Not Found' do
      header 'authorization', "Bearer #{@token}"
      patch_json '/api/v1/users/foo', firstname: 'john'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end

  context 'when given an invalid id' do
    it 'should return 404 Not Found' do
      header 'authorization', "Bearer #{@token}"
      patch_json "/api/v1/users/#{SecureRandom.uuid}", firstname: 'john'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end

  context 'without HTTP_IF_MATCH' do
    it 'should return 428 Precondition Required' do
      header 'authorization', "Bearer #{@token}"
      patch_json "/api/v1/users/#{@jane.id}", firstname: 'john'
      expect(last_response.status).to eq(428)
      expect(last_response.body).to be_empty
    end
  end

  context 'with a stale resource' do
    it 'should return 412 Precondition Failed' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(SecureRandom.uuid)
      patch_json "/api/v1/users/#{@jane.id}", firstname: 'john'
      expect(last_response.status).to eq(412)
      expect(last_response.body).to be_empty
    end
  end

  describe 'firstname' do
    it 'should not be empty' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", firstname: ''
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('length must be within 1 - 255')
    end
    it 'should not be too long' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", firstname: 'x' * 256
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to include('length must be within 1 - 255')
    end
    it 'should be stripped and capitalized' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", firstname: " john\n"
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:firstname]).to eq('John')
    end
  end

  describe 'lastname' do
    it 'should not be empty' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", lastname: ''
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('length must be within 1 - 255')
    end
    it 'should not be too long' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", lastname: 'x' * 256
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to include('length must be within 1 - 255')
    end
    it 'should be stripped and capitalized' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", lastname: "\tDoE\n "
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:lastname]).to eq('Doe')
    end
  end

  describe 'birthdate' do
    it 'should be a date' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", birthdate: 'not a date'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include('must be a date')
    end
    it 'should be in the past' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", birthdate: Date.today
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to include("must be less than #{Date.today}")
    end
    it 'should be stripped and ISO8601' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", birthdate: " 5 Nov 1605\n"
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:birthdate]).to eq('1605-11-05')
    end
  end

  describe 'gender' do
    it 'should be either male of female' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", gender: '?'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:gender]).to include('must be one of: female, male')
    end
    it 'should be stripped and downcased' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", gender: '  MALE '
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:gender]).to eq('male')
    end
  end

  describe 'login' do
    it 'should be required when password is provided' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", password: 'secret'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('must be filled')
    end
    it 'should not be too short' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", login: '12'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('length must be within 3 - 255')
    end
    it 'should not be too long' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", login: 'x' * 256
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to include('length must be within 3 - 255')
    end
    it 'should be stripped and capitalized' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", build(:user, :with_credentials, login: " JoHn\t")
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:login]).to eq('john')
    end
  end

  describe 'password' do
    it 'should be required when login is provided' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", login: 'john'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:password]).to include('must be filled')
    end
    it 'should not be too short' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", password: '12345'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:password]).to include('size cannot be less than 6')
    end
    it 'should not be returned' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", build(:user, :with_credentials)
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).not_to include(:password)
    end
  end

  describe 'version' do
    it 'should have changed' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(@jane.version)
      patch_json "/api/v1/users/#{@jane.id}", build(:user, :with_credentials)
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:version]).not_to eq(@jane.version)
    end
  end

  context 'when the user has credentials' do
    before(:each) do
      result = create_user build(:user, :with_credentials, firstname: 'leia')
      expect(result).to be_success
      @leia = result.value!
    end

    describe 'login' do
      it 'should not be required to change the password' do
        header 'authorization', "Bearer #{@token}"
        header 'if-match', etag(@leia.version)
        patch_json "/api/v1/users/#{@leia.id}", password: 'secret'
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
      end
      it 'should be unique' do
        header 'authorization', "Bearer #{@token}"
        header 'if-match', etag(@leia.version)
        patch_json "/api/v1/users/#{@leia.id}", login: @current_user.login, password: 'secret'
        expect(last_response.status).to eq(409)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:login]).to eq('is already taken')
      end
    end

    describe 'password' do
      it 'should not be required to change the login' do
        header 'authorization', "Bearer #{@token}"
        header 'if-match', etag(@leia.version)
        patch_json "/api/v1/users/#{@leia.id}", login: 'john'
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
      end
    end
  end

  it 'should update the matching user' do
    header 'authorization', "Bearer #{@token}"
    header 'if-match', etag(@jane.version)
    patch_json "/api/v1/users/#{@jane.id}", firstname: 'john'
    expect(last_response.status).to eq(200)
    expect(found = find_user(@jane.id)).to be_success
    expect(json_body).to eq(hiphop(found.value!))
  end
end
