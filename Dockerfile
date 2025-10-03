FROM nginx:latest

# Copy all your project files into the Nginx HTML directory
COPY . /usr/share/nginx/html/

#expose port 80
EXPOSE 80

#start Nginx
CMD ["nginx", "-g", "daemon off;"]

