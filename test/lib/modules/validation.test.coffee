# Copyright (c) 2016 Kinvey Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.

should = require 'should'
validationModule = require '../../../lib/service/modules/validation'

describe 'modules / validation', () ->
  it 'throws an error if first argument is not specified or not an object', (done) ->
    (-> validationModule.doValidation()).should.throw()
    (-> validationModule.doValidation(null, {})).should.throw()
    (-> validationModule.doValidation(1, {})).should.throw()
    (-> validationModule.doValidation(true, {})).should.throw()
    done()

  it 'throws an error if second argument is not specified or not an object', (done) ->
    (-> validationModule.doValidation({})).should.throw()
    (-> validationModule.doValidation({}, null)).should.throw()
    (-> validationModule.doValidation({}, 1)).should.throw()
    (-> validationModule.doValidation({}, true)).should.throw()
    done()


  it 'can validate multiple properties successfully', (done) ->
    spec =
      requiredProp:
        required: true
      requiredProp2:
        required: true
      rangeProp:
        min: 0
        max: 200

    validationResults = validationModule.doValidation spec, { requiredProp: 123, requiredProp2: true, rangeProp: 10 }
    Array.isArray(validationResults).should.be.true
    validationResults.length.should.eql 0
    done()

  it 'returns an array of errors if validation fails for any properties', (done) ->
    spec =
      requiredProp:
        required: true
      requiredProp2:
        required: true
      rangeProp:
        min: 0
        max: 200

    validationResults = validationModule.doValidation spec, { requiredProp: 123, rangeProp: 300 }
    Array.isArray(validationResults).should.be.true
    validationResults.length.should.eql 2
    validationResults[0].attr.should.eql 'requiredProp2'
    validationResults[1].attr.should.eql 'rangeProp'
    done()

  describe 'types / required', () ->
    it 'returns an empty array on successful validation', (done) ->
      spec =
        requiredProp:
          required: true

      validationResults = validationModule.doValidation spec, { requiredProp: 123 }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 0
      done()

    it 'returns an error if validation is unsuccessful', (done) ->
      spec =
        requiredProp:
          required: true

      validationResults = validationModule.doValidation spec, {}
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 1
      validationResults[0].should.have.properties ['valid', 'attr', 'msg']
      validationResults[0].valid.should.be.false
      validationResults[0].attr.should.eql 'requiredProp'
      validationResults[0].msg.should.eql 'requiredProp is required'
      done()

  describe 'types / min', () ->
    it 'returns an empty array on successful validation', (done) ->
      spec =
        rangeProp:
          min: 100

      validationResults = validationModule.doValidation spec, { rangeProp: 123 }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 0
      done()

    it 'returns an error if validation is unsuccessful', (done) ->
      spec =
        rangeProp:
          min: 100

      validationResults = validationModule.doValidation spec, { rangeProp: 0 }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 1
      validationResults[0].should.have.properties ['valid', 'attr', 'msg']
      validationResults[0].valid.should.be.false
      validationResults[0].attr.should.eql 'rangeProp'
      validationResults[0].msg.should.eql 'rangeProp must be greater than or equal to 100'
      done()

    it 'validation is successful if value is equal to range limit', (done) ->
      spec =
        rangeProp:
          min: 100

      validationResults = validationModule.doValidation spec, { rangeProp: 100 }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 0
      done()

  describe 'types / max', () ->
    it 'returns an empty array on successful validation', (done) ->
      spec =
        rangeProp:
          max: 100

      validationResults = validationModule.doValidation spec, { rangeProp: 50 }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 0
      done()

    it 'returns an error if validation is unsuccessful', (done) ->
      spec =
        rangeProp:
          max: 100

      validationResults = validationModule.doValidation spec, { rangeProp: 150 }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 1
      validationResults[0].should.have.properties ['valid', 'attr', 'msg']
      validationResults[0].valid.should.be.false
      validationResults[0].attr.should.eql 'rangeProp'
      validationResults[0].msg.should.eql 'rangeProp must be less than or equal to 100'
      done()

    it 'validation is successful if value is equal to range limit', (done) ->
      spec =
        rangeProp:
          max: 100

      validationResults = validationModule.doValidation spec, { rangeProp: 100 }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 0
      done()

  describe 'types / pattern', () ->
    it 'returns an empty array on successful validation', (done) ->
      spec =
        regExProp:
          pattern: ['hello']

      validationResults = validationModule.doValidation spec, { regExProp: 'hello, bob' }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 0
      done()

    it 'returns an error array if validation is unsuccessful', (done) ->
      spec =
        regExProp:
          pattern: ['hello']

      validationResults = validationModule.doValidation spec, { regExProp: 'hi, bob' }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 1
      validationResults[0].should.have.properties ['valid', 'attr', 'msg']
      validationResults[0].valid.should.be.false
      validationResults[0].attr.should.eql 'regExProp'
      Array.isArray(validationResults[0].msg).should.be.true
      validationResults[0].msg.length.should.eql 1
      validationResults[0].msg[0].should.eql 'regExProp must match regex of hello'
      done()

    it 'can succesfully validate against multiple regular expressions', (done) ->
      spec =
        regExProp:
          pattern: ['hello', 'bob']

      validationResults = validationModule.doValidation spec, { regExProp: 'hello, bob' }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 0
      done()

    it 'returns an error array if multiple regex validation is unsuccessful', (done) ->
      spec =
        regExProp:
          pattern: ['hello', 'hi', 'john']

      validationResults = validationModule.doValidation spec, { regExProp: 'hi, bob' }
      Array.isArray(validationResults).should.be.true
      validationResults.length.should.eql 1
      validationResults[0].should.have.properties ['valid', 'attr', 'msg']
      validationResults[0].valid.should.be.false
      validationResults[0].attr.should.eql 'regExProp'
      Array.isArray(validationResults[0].msg).should.be.true
      validationResults[0].msg.length.should.eql 2
      validationResults[0].msg[0].should.eql 'regExProp must match regex of hello'
      validationResults[0].msg[1].should.eql 'regExProp must match regex of john'
      done()
