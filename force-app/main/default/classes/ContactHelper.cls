public class ContactHelper {
    // Helper method to normalize phone numbers
    public static String normalizePhone(String phone) {
        if (String.isEmpty(phone)) return null;

        // Remove non-numeric characters
        phone = phone.replaceAll('[^\\d]', '');

        // Handle cases like country code normalization if needed
        if (phone.startsWith('91') && phone.length() > 10) {
            phone = phone.substring(2); // Remove leading country code for Indian numbers
        }

        return phone;
    }
}