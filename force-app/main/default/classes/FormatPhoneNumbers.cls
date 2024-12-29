public class FormatPhoneNumbers {

    // Map of country codes
    public static Map<String, String> countryCodeMap = new Map<String, String>{
        'Afghanistan' => '93',
        'Albania' => '355',
        'Algeria' => '213',
        'American Samoa' => '1-684',
        'Andorra' => '376',
        'Angola' => '244',
        'Anguilla' => '1-264',
        'Antarctica' => '672',
        'Antigua and Barbuda' => '1-268',
        'Argentina' => '54',
        'Armenia' => '374',
        'Aruba' => '297',
        'Australia' => '61',
        'Austria' => '43',
        'Azerbaijan' => '994',
        'Bahamas' => '1-242',
        'Bahrain' => '973',
        'Bangladesh' => '880',
        'Barbados' => '1-246',
        'Belarus' => '375',
        'Belgium' => '32',
        'Belize' => '501',
        'Benin' => '229',
        'Bermuda' => '1-441',
        'Bhutan' => '975',
        'Bolivia' => '591',
        'Bosnia and Herzegovina' => '387',
        'Botswana' => '267',
        'Brazil' => '55',
        'British Indian Ocean Territory' => '246',
        'British Virgin Islands' => '1-284',
        'Brunei' => '673',
        'Bulgaria' => '359',
        'Burkina Faso' => '226',
        'Burundi' => '257',
        'Cambodia' => '855',
        'Cameroon' => '237',
        'Canada' => '1',
        'Cape Verde' => '238',
        'Cayman Islands' => '1-345',
        'Central African Republic' => '236',
        'Chad' => '235',
        'Chile' => '56',
        'China' => '86',
        'Christmas Island' => '61',
        'Cocos Islands' => '61',
        'Colombia' => '57',
        'Comoros' => '269',
        'Cook Islands' => '682',
        'Costa Rica' => '506',
        'Croatia' => '385',
        'Cuba' => '53',
        'Curacao' => '599',
        'Cyprus' => '357',
        'Czech Republic' => '420',
        'Democratic Republic of the Congo' => '243',
        'Denmark' => '45',
        'Djibouti' => '253',
        'Dominica' => '1-767',
        'Dominican Republic' => '1-809, 1-829, 1-849',
        'East Timor' => '670',
        'Ecuador' => '593',
        'Egypt' => '20',
        'El Salvador' => '503',
        'Equatorial Guinea' => '240',
        'Eritrea' => '291',
        'Estonia' => '372',
        'Ethiopia' => '251',
        'Falkland Islands' => '500',
        'Faroe Islands' => '298',
        'Fiji' => '679',
        'Finland' => '358',
        'France' => '33',
        'French Polynesia' => '689',
        'Gabon' => '241',
        'Gambia' => '220',
        'Georgia' => '995',
        'Germany' => '49',
        'Ghana' => '233',
        'Gibraltar' => '350',
        'Greece' => '30',
        'Greenland' => '299',
        'Grenada' => '1-473',
        'Guam' => '1-671',
        'Guatemala' => '502',
        'Guernsey' => '44-1481',
        'Guinea' => '224',
        'Guinea-Bissau' => '245',
        'Guyana' => '592',
        'Haiti' => '509',
        'Honduras' => '504',
        'Hong Kong' => '852',
        'Hungary' => '36',
        'Iceland' => '354',
        'India' => '91',
        'Indonesia' => '62',
        'Iran' => '98',
        'Iraq' => '964',
        'Ireland' => '353',
        'Isle of Man' => '44-1624',
        'Israel' => '972',
        'Italy' => '39',
        'Ivory Coast' => '225',
        'Jamaica' => '1-876',
        'Japan' => '81',
        'Jersey' => '44-1534',
        'Jordan' => '962',
        'Kazakhstan' => '7',
        'Kenya' => '254',
        'Kiribati' => '686',
        'Kosovo' => '383',
        'Kuwait' => '965',
        'Kyrgyzstan' => '996'
        // Add other countries as needed
    };

    public static void formatContacts() {
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact c : [SELECT Id, MobilePhone, Country__c, phoneId__c FROM Contact WHERE MobilePhone != null]) {
            String cleanedNumber = cleanPhoneNumber(c.MobilePhone);
            System.debug('Original Number: ' + c.MobilePhone + ', Cleaned Number: ' + cleanedNumber);

            if (cleanedNumber.length() < 8) {
                c.MobilePhone = null;
                c.phoneId__c = null;
                System.debug('Number less than 8 digits. Setting MobilePhone and phoneId__c to null.');
            } else if (cleanedNumber.length() <= 15) {
                String countryCode = countryCodeMap.get(c.Country__c);
                if (countryCode != null) {
                    c.MobilePhone = '+' + countryCode + cleanedNumber;
                    c.phoneId__c = cleanedNumber; // Ensure phoneId__c is numeric only
                    System.debug('Formatted Number: ' + c.MobilePhone + ', phoneId__c: ' + c.phoneId__c);
                } else {
                    c.MobilePhone = null; // Optionally handle unknown country codes
                    c.phoneId__c = null;
                    System.debug('Unknown country code. Setting MobilePhone and phoneId__c to null.');
                }
            }
            contactsToUpdate.add(c);
        }

        System.debug('Contacts to update: ' + contactsToUpdate);

        try {
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
                System.debug('Updated contacts: ' + contactsToUpdate);
            } else {
                System.debug('No contacts to update.');
            }
        } catch (DmlException e) {
            System.debug('Update failed: ' + e.getMessage());
        }
    }

    public static String cleanPhoneNumber(String phoneNumber) {
        return phoneNumber.replaceAll('[^0-9]', '');
    }
}