# frozen_string_literal: true

describe 'users update end-point', :transaction do
  before(:each) do
    result = create_user.call build(:user, name: 'jane')
    expect(result).to be_success
    @user = result.value!
  end

  context 'when given malformed id' do
    it 'should return 404 Not Found' do
      patch_json '/api/v1/users/foo', firstname: 'john'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
      expect(found = find_user.call(@user.id)).to be_success
      expect(found.value!).to eq(@user)
    end
  end
  context 'when given an invalid id' do
    it 'should return 404 Not Found' do
      patch_json "/api/v1/users/#{SecureRandom.uuid}", firstname: 'john'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
      expect(found = find_user.call(@user.id)).to be_success
      expect(found.value!).to eq(@user)
    end
  end

  context 'when given a valid id' do
    describe 'firstname' do
      it 'should not be empty' do
        patch_json "/api/v1/users/#{@user.id}", firstname: ''
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:firstname]).to include('length must be within 1 - 255')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should not be too long' do
        patch_json "/api/v1/users/#{@user.id}", firstname: 'x' * 256
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:firstname]).to include('length must be within 1 - 255')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should be stripped and capitalized' do
        patch_json "/api/v1/users/#{@user.id}", firstname: " john\n"
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:firstname]).to eq('John')
        expect(found = find_user.call(@user.id)).to be_success
        expect(json_body).to eq(hiphop(found.value!))
      end
    end

    describe 'lastname' do
      it 'should not be empty' do
        patch_json "/api/v1/users/#{@user.id}", lastname: ''
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:lastname]).to include('length must be within 1 - 255')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should not be too long' do
        patch_json "/api/v1/users/#{@user.id}", lastname: 'x' * 256
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:lastname]).to include('length must be within 1 - 255')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should be stripped and capitalized' do
        patch_json "/api/v1/users/#{@user.id}", lastname: "\tDoE\n "
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:lastname]).to eq('Doe')
        expect(found = find_user.call(@user.id)).to be_success
        expect(json_body).to eq(hiphop(found.value!))
      end
    end

    describe 'birthdate' do
      it 'should be a date' do
        patch_json "/api/v1/users/#{@user.id}", birthdate: 'not a date'
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:birthdate]).to include('must be a date')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should be in the past' do
        patch_json "/api/v1/users/#{@user.id}", birthdate: Date.today
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:birthdate]).to include("must be less than #{Date.today}")
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should be stripped and ISO8601' do
        patch_json "/api/v1/users/#{@user.id}", birthdate: " 5 Nov 1605\n"
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:birthdate]).to eq('1605-11-05')
        expect(found = find_user.call(@user.id)).to be_success
        expect(json_body).to eq(hiphop(found.value!))
      end
    end

    describe 'gender' do
      it 'should be either male of female' do
        patch_json "/api/v1/users/#{@user.id}", gender: '?'
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:gender]).to include('must be one of: female, male')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should be stripped and downcased' do
        patch_json "/api/v1/users/#{@user.id}", gender: '  MALE '
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:gender]).to eq('male')
        expect(found = find_user.call(@user.id)).to be_success
        expect(json_body).to eq(hiphop(found.value!))
      end
    end

    describe 'login' do
      it 'should be required when password is provided' do
        patch_json "/api/v1/users/#{@user.id}", password: 'secret'
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:login]).to include('must be filled')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should not be too short' do
        patch_json "/api/v1/users/#{@user.id}", login: '12'
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:login]).to include('length must be within 3 - 255')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should not be too long' do
        patch_json "/api/v1/users/#{@user.id}", login: 'x' * 256
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:login]).to include('length must be within 3 - 255')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should be stripped and capitalized' do
        patch_json "/api/v1/users/#{@user.id}", build(:user, :with_credentials, login: " JoHn\t")
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:login]).to eq('john')
        expect(found = find_user.call(@user.id)).to be_success
        expect(json_body).to eq(hiphop(found.value!))
      end
    end

    describe 'password' do
      it 'should be required when login is provided' do
        patch_json "/api/v1/users/#{@user.id}", login: 'john'
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:password]).to include('must be filled')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should not be too short' do
        patch_json "/api/v1/users/#{@user.id}", password: '12345'
        expect(last_response.status).to eq(400)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body[:password]).to include('size cannot be less than 6')
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
      it 'should not be returned' do
        patch_json "/api/v1/users/#{@user.id}", build(:user, :with_credentials)
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(json_body).not_to include(:password)
        expect(found = find_user.call(@user.id)).to be_success
        expect(json_body).to eq(hiphop(found.value!))
      end
    end

    context 'when the user has credentials' do
      before(:each) do
        result = create_user.call build(:user, :with_credentials)
        expect(result).to be_success
        @user = result.value!
      end

      describe 'login' do
        it 'should not be required to change the password' do
          patch_json "/api/v1/users/#{@user.id}", password: 'secret'
          expect(last_response.status).to eq(200)
          expect(last_response.content_type).to eq('application/json')
          expect(found = find_user.call(@user.id)).to be_success
          expect(json_body).to eq(hiphop(found.value!))
        end
      end

      describe 'password' do
        it 'should not be required to change the login' do
          patch_json "/api/v1/users/#{@user.id}", login: 'john'
          expect(last_response.status).to eq(200)
          expect(last_response.content_type).to eq('application/json')
          expect(found = find_user.call(@user.id)).to be_success
          expect(json_body).to eq(hiphop(found.value!))
        end
      end
    end

    context 'when there is another user with credentials' do
      before(:each) do
        result = create_user.call build(:user, :with_credentials)
        expect(result).to be_success
        @other = result.value!
      end

      describe 'login' do
        it 'should be unique' do
          patch_json "/api/v1/users/#{@user.id}", build(:user, :with_credentials, login: @other.login)
          expect(last_response.status).to eq(400)
          expect(last_response.content_type).to eq('application/json')
          expect(json_body[:login]).to eq('is already taken')
          expect(found = find_user.call(@user.id)).to be_success
          expect(found.value!).to eq(@user)
        end
      end
    end

    describe 'HTTP_LAST_MODIFIED' do
      it 'should be the same as updated_at' do
        patch_json "/api/v1/users/#{@user.id}", firstname: 'john'
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(last_response.header['last-modified']).to be
        last_modified = DateTime.httpdate(last_response.header['last-modified'])
        updated_at = DateTime.iso8601(json_body[:updated_at])
        expect(last_modified).to eq(updated_at)
      end
    end

    it 'should update the matching user' do
      patch_json "/api/v1/users/#{@user.id}", firstname: 'john'
      expect(last_response.status).to eq(200)
      expect(found = find_user.call(@user.id)).to be_success
      expect(json_body).to eq(hiphop(found.value!))
    end

    context 'with an up-to-date resource' do
      it 'should update the matching user' do
        header 'if-unmodified-since', @user.updated_at.httpdate
        patch_json "/api/v1/users/#{@user.id}", firstname: 'john'
        expect(last_response.status).to eq(200)
        expect(found = find_user.call(@user.id)).to be_success
        expect(json_body).to eq(hiphop(found.value!))
      end
    end

    context 'with a stale resource' do
      it 'should return 412 Precondition Failed' do
        header 'if-unmodified-since', (@user.updated_at - 1).httpdate
        patch_json "/api/v1/users/#{@user.id}", firstname: 'john'
        expect(last_response.status).to eq(412)
        expect(last_response.body).to be_empty
        expect(found = find_user.call(@user.id)).to be_success
        expect(found.value!).to eq(@user)
      end
    end
  end
end
