

    public static class EnumHelper
    {
        public static T GetEnumValueFromString<T>(string value) where T : Enum
        {
            // Get the type of the enum
            Type enumType = typeof(T);

            // Loop through each enum value
            foreach (var field in enumType.GetFields())
            {
                // Get the EnumMember attribute
                var attribute = field.GetCustomAttributes(typeof(EnumMemberAttribute), false)
                                      .FirstOrDefault() as EnumMemberAttribute;

                if (attribute != null && attribute.Value == value)
                {
                    return (T)field.GetValue(null);
                }
            }

            throw new ArgumentException($"No enum value found for '{value}'", nameof(value));
        }

        public static bool DoesEnumValueExist<T>(string value) where T : Enum
        {
            // Get the type of the enum
            Type enumType = typeof(T);

            // Loop through each enum value
            foreach (var field in enumType.GetFields())
            {
                // Get the EnumMember attribute
                var attribute = field.GetCustomAttributes(typeof(EnumMemberAttribute), false)
                                      .FirstOrDefault() as EnumMemberAttribute;

                if (attribute != null && attribute.Value == value)
                {
                    return true;
                }
            }

            return false;
        }
    }