using ImageMagick;
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

namespace BuildOnTechnologies.VDS.Legacy.Dal.Helpers
{
    public static class ImageHelper
    {
        /// <summary>
        /// Used to resize byte array images.
        /// </summary>
        /// <param name="imageBytes">The original image byte array</param>
        /// <param name="maxWidth">The maximum width the returned image can be</param>
        /// <param name="maxHeight">The maximum height the returned image can be</param>
        /// <param name="outFormat">The output format of the returned image</param>
        /// <returns></returns>
        public static byte[] ResizeImage(byte[] imageBytes, int maxWidth, int maxHeight, ImageFormat outputFormat)
        {
            try
            {
                //if the image data is null, just exit this function
                if (imageBytes == null)
                {
                    return null;
                }

                using (MemoryStream ms = new MemoryStream(imageBytes))
                {
                    Image image = Image.FromStream(ms, true);
                    MemoryStream imageStream = new MemoryStream();

                    try
                    {
                        if (image.Width > maxWidth || image.Height > maxHeight)
                        {
                            double aspectRatio;
                            double wRatio = (double)maxWidth / (double)image.Width;
                            double hRatio = (double)maxHeight / (double)image.Height;

                            if (wRatio < hRatio)
                                aspectRatio = wRatio;
                            else
                                aspectRatio = hRatio;

                            int newWidth = (int)(image.Width * aspectRatio);
                            int newHeight = (int)(image.Height * aspectRatio);

                            image = new Bitmap(image, new Size(newWidth, newHeight));
                        }

                        ImageCodecInfo imageCodecInfo = GetEncoderInfo(outputFormat);
                        EncoderParameters imageEncoderParameters = new EncoderParameters(1);
                        imageEncoderParameters.Param[0] = new EncoderParameter(Encoder.Quality, 65L);

                        image.Save(imageStream, imageCodecInfo, imageEncoderParameters);
                        imageBytes = imageStream.ToArray();

                        image.Dispose();
                        imageStream.Dispose();
                    }
                    catch (Exception)
                    {
                        image.Dispose();
                        imageStream.Dispose();
                    }
                }

                return imageBytes;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public static byte[] InvertImage(byte[] imageBytes)
        {
            MemoryStream origMS = new MemoryStream(imageBytes);
            Image img = Image.FromStream(origMS);
            origMS.Dispose();

            Color pixel;
            Color color;
            Bitmap bmp = new Bitmap(img);

            for (int y = 0; y < bmp.Height; y++)
            {
                for (int x = 0; x < bmp.Width; x++)
                {
                    pixel = bmp.GetPixel(x, y);
                    color = Color.FromArgb(pixel.A, 255 - pixel.R, 255 - pixel.G, 255 - pixel.B);
                    bmp.SetPixel(x, y, color);
                }
            }

            MemoryStream invertedMS = new MemoryStream();
            bmp.Save(invertedMS, ImageFormat.Png);
            var invertedImageData = invertedMS.ToArray();
            invertedMS.Dispose();

            return invertedImageData;
        }

        private static ImageCodecInfo GetEncoderInfo(ImageFormat imageFormat)
        {
            int j;
            ImageCodecInfo[] encoders;
            encoders = ImageCodecInfo.GetImageEncoders();
            for (j = 0; j < encoders.Length; ++j)
            {
                if (encoders[j].FormatID == imageFormat.Guid)
                    return encoders[j];
            }
            return null;
        }

        public static byte[] RotateImage(byte[] imageBytes, double rotateDegree)
        {
            if (imageBytes != null && rotateDegree > 0)
            {
                using (MagickImage img = new MagickImage(imageBytes))
                {
                    img.Rotate(rotateDegree);

                    return img.ToByteArray();
                }
            }

            return imageBytes;
        }

        public static void ValidateImageData(byte[] data)
        {
            try
            {
                using (var image = SixLabors.ImageSharp.Image.Load(data))
                {
                    return; // the image has successfully loaded, so the format is supported
                }
            }
            catch
            {
                throw new NotSupportedException("The image data is invalid.");
            }
        }
    }
}