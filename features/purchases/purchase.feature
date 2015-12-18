@javascript
Feature: Purchase
  In order to buy a book
  A user
  Should be able to create an instant purchase

    Scenario: User is not signed up
      Given I do not exist as a user
      When I fill out the purchase form
      Then I should be signed in
        And I should see a complete sale purchase form
        And I should have a new user
        And I should have a new sale
        And my address should be decryptable by the development machines
        And I should have a matching cost
      Then the user should be able to see that they've made a bitcoin_payment
      Then the downloader should be able to notice their purchase
      Then the downloader should be able to download the purchase data
      Then shipping should be able to upload the purchase data
      Then shipping should be able to see shipping orders to print
      Then shipping should be able to download the address completion file
      Then the downloader should be able to upload the address completion file
        And the sale should be marked as shipped
      Then the user should be able to see that their sale has been shipped
