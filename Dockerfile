# Step 1: Use a tiny Nginx image as the base
FROM nginx:alpine

# Step 2: Copy the Flutter build output to the Nginx html folder
# This assumes you have already run 'flutter build web --release'
COPY build/web /usr/share/nginx/html

# Step 3: Expose port 80 (the default Nginx port)
EXPOSE 80

# Step 4: Start Nginx
CMD ["nginx", "-g", "daemon off;"]